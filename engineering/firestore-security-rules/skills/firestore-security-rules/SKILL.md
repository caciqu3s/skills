---
name: firestore-security-rules
description: Use this when authoring, reviewing, testing, or debugging Firestore or Cloud Storage security rules. Apply it for ownership checks, RBAC, server-only collections, append-only records, status-gated reads, storage validation, and Firebase emulator rule tests.
---

# Firestore and Storage security rules delivery

Use this skill when a task touches `firestore.rules`, `storage.rules`, Firebase emulator tests for rules, Firestore collection access control, or Storage object validation.

Do **not** use this skill for application-only Firestore SDK queries when no rule behavior changes or rule assumptions are involved.

## Mission

When working on Firebase security rules:

- default to deny-by-default access
- encode ownership and role boundaries explicitly
- validate create and update paths separately
- treat client-provided role, owner, status, or admin fields as untrusted
- write or update emulator-backed tests for meaningful rule changes
- keep rule helpers small, readable, and aligned with the application's collection path conventions

Rules are security code. They must be reviewed and tested like backend authorization logic.

## Required workflow

1. Identify the protected resources.
   - Firestore collections and nested paths
   - Storage buckets and object path patterns
   - user-scoped, admin-only, public-read, server-only, append-only, and status-gated resources
2. Identify the source of authority.
   - `request.auth.uid`
   - custom claims such as `request.auth.token.role`
   - server-written user profile documents
   - immutable document fields such as `ownerId` or `userId`
3. Define helper functions before writing repeated rules.
4. Model create, read, update, and delete separately.
5. Prevent update bypasses by validating both old and new document state.
6. Add Storage size and MIME/type validation when files are accepted.
7. Add or update emulator tests for success and failure paths.
8. Run rule tests through the repository's existing test command or emulator workflow.

If the intended authorization model is unclear, ask who can create, read, update, delete, and administer each resource before writing permissive rules.

## Firestore rule standards

Use `rules_version = '2';`.

Prefer this structure:

```firebase
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isOwner(userId)
        && request.resource.data.uid == request.auth.uid;
      allow update: if isOwner(userId)
        && resource.data.uid == request.auth.uid
        && request.resource.data.uid == resource.data.uid;
      allow delete: if false;
    }
  }
}
```

### Ownership

- Prefer path ownership such as `/users/{userId}` with `request.auth.uid == userId`.
- If a document has `ownerId`, require it on create and prevent changes on update.
- Do not authorize sensitive access from `request.resource.data.role`, `isAdmin`, `ownerId`, or similar fields supplied by the client.

### Roles and RBAC

Use custom claims when roles are set by trusted backend code and need to be cheap to read:

```firebase
function hasRole(role) {
  return request.auth != null && request.auth.token.role == role;
}
```

Use Firestore profile lookup only when the project intentionally stores role state in documents:

```firebase
function currentUserRole() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
}
```

Do not mix custom-claim and Firestore-profile role sources casually. Pick one authority per access path and document the assumption.

### Server-only collections

For data written only by Admin SDK, Cloud Functions, Cloud Run, or trusted backend jobs:

```firebase
match /auditLogs/{logId} {
  allow read, write: if false;
}
```

Admin SDK bypasses rules. Client SDKs must not access server-only collections directly.

### Append-only records

For audit logs, events, immutable transactions, or submissions:

```firebase
match /events/{eventId} {
  allow create: if isAuthenticated()
    && request.resource.data.userId == request.auth.uid;
  allow update, delete: if false;
}
```

### Status-gated reads

For draft/finalized workflows:

```firebase
allow read: if isOwner(resource.data.userId)
  || resource.data.status == 'finalized';
```

Be explicit about which status values are public, private, or admin-only.

## Storage rule standards

Always validate ownership, size, and content type for user uploads:

```firebase
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }

    match /users/{userId}/uploads/{fileName} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId)
        && request.resource.size < 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```

Do not allow arbitrary authenticated users to upload unlimited files.

## Emulator test standards

Use `@firebase/rules-unit-testing` for rule tests. In this workspace, prefer Vitest when the project already uses it.

Required patterns:

- `initializeTestEnvironment`
- `assertSucceeds`
- `assertFails`
- `withSecurityRulesDisabled` for seeding trusted fixture data
- `clearFirestore()` or equivalent cleanup between tests
- emulator host/port configured explicitly when needed

Example:

```ts
import { readFileSync } from 'node:fs';
import { assertFails, assertSucceeds, initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { beforeAll, beforeEach, describe, it } from 'vitest';

describe('firestore rules', () => {
  let testEnv: Awaited<ReturnType<typeof initializeTestEnvironment>>;

  beforeAll(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: 'demo-test',
      firestore: {
        rules: readFileSync('firestore.rules', 'utf8'),
        host: '127.0.0.1',
        port: 8080,
      },
    });
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  it('allows an owner to read their document', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/alice').set({ uid: 'alice' });
    });

    const db = testEnv.authenticatedContext('alice').firestore();
    await assertSucceeds(db.doc('users/alice').get());
  });

  it('blocks other users', async () => {
    const db = testEnv.authenticatedContext('bob').firestore();
    await assertFails(db.doc('users/alice').get());
  });
});
```

Rules tests require the Firebase emulator. Do not replace emulator tests with mocked Firestore SDK behavior.

## Security review checklist

Before declaring rules complete, actively try to bypass them:

- Can a user create a valid document and then update it into an invalid state?
- Can a user change `role`, `ownerId`, `uid`, `status`, or ACL fields?
- Are create and update validations consistent?
- Are reads scoped by owner, role, or final/public status?
- Are server-only collections inaccessible to clients?
- Are arrays and strings size-limited where abuse is plausible?
- Are required fields typed?
- Does Storage validate owner, size, and MIME type?
- Do tests include both `assertSucceeds` and `assertFails` for the important paths?

## Refusal and boundary rules

- Do not write `allow read, write: if true` except in disposable local-only examples explicitly marked as insecure.
- Do not authorize admin behavior from client-writable fields.
- Do not remove existing restrictive rules without replacing them with equivalent or stronger authorization.
- Do not claim rules are secure if emulator tests were not added or updated for changed behavior.
- Do not use broad catch-all matches to make tests pass.

## Supplemental guidance

Use the companion checklist in [DELIVERY-CHECKLIST.md](./DELIVERY-CHECKLIST.md) before delivery.
