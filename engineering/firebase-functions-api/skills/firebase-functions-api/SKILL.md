---
name: firebase-functions-api
description: Use this when creating or changing Firebase Cloud Functions TypeScript APIs, including v2 callable or HTTP functions, Express or NestJS adapters, Firebase Admin SDK access, custom claims, Firestore writes, emulator workflows, and backend validation.
---

# Firebase Functions v2 TypeScript API delivery

Use this skill when a task touches Firebase Cloud Functions, callable APIs, HTTP APIs deployed as functions, backend Firestore access with Admin SDK, custom claims, or Firebase emulator-backed backend development.

Do **not** use this skill for frontend-only Firebase client SDK changes unless the task also changes callable contracts, backend authorization, or Firestore rules.

## Mission

When implementing Firebase Functions APIs:

- prefer Firebase Functions v2 for new code
- keep handlers small and delegate domain logic to typed services
- validate auth and input before side effects
- return typed, predictable responses
- use `HttpsError` for callable failures
- initialize Firebase Admin SDK once at module scope
- support emulator-first local development
- preserve low-cost, serverless-first defaults

## Required workflow

1. Identify the trigger type.
   - `onCall` for authenticated app calls and typed client interactions
   - `onRequest` for webhooks, public HTTP endpoints, Express/NestJS adapters, or non-Firebase clients
   - scheduled, document, or pub/sub triggers only when the workflow needs them
2. Inspect the existing function style.
   - raw handler
   - Express app
   - NestJS app
   - tRPC or another router inside Express
3. Define the request contract.
   - auth requirement
   - input schema
   - output schema
   - error codes
   - idempotency or retry behavior
4. Add or update service-layer logic outside the handler.
5. Wire Admin SDK access through shared helpers where they exist.
6. Update Firestore rules, shared types, or frontend client calls if the contract changes.
7. Run the repository's existing build, typecheck, test, or emulator validation commands.

If auth, data ownership, or retry semantics are unclear, ask before implementing side effects.

## Firebase Functions v2 standards

Use v2 imports for new functions:

```ts
import { HttpsError, onCall, onRequest } from 'firebase-functions/v2/https';
```

Do not introduce `firebase-functions/v1` for new code unless the repository already depends on a v1-only trigger or migration constraint.

### Callable function pattern

Use `onCall` for app-client calls where Firebase Auth context is expected.

```ts
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { z } from 'zod';
import './firebase-admin';

const InputSchema = z.object({
  vehicleId: z.string().min(1),
});

export const analyzeVehicle = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication is required.');
  }

  const input = InputSchema.safeParse(request.data);
  if (!input.success) {
    throw new HttpsError('invalid-argument', 'Invalid request payload.', {
      issues: input.error.issues,
    });
  }

  const db = getFirestore();
  const doc = await db
    .collection('users')
    .doc(request.auth.uid)
    .collection('vehicles')
    .doc(input.data.vehicleId)
    .get();

  if (!doc.exists) {
    throw new HttpsError('not-found', 'Vehicle not found.');
  }

  return { vehicle: doc.data() };
});
```

Callable handler rules:

- check `request.auth` before reading or writing user data
- validate `request.data` with an existing schema library when available
- use `HttpsError` codes instead of generic `Error`
- do not leak raw provider errors to clients
- keep response objects JSON-serializable

### HTTP function pattern

Use `onRequest` for webhooks, public APIs, health checks, or Express/NestJS adapters.

```ts
import express from 'express';
import { onRequest } from 'firebase-functions/v2/https';

const app = express();

app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

export const api = onRequest(app);
```

For webhooks:

- validate signatures before parsing or trusting payloads
- return fast 2xx responses only after durable acceptance
- make handlers idempotent when the provider can retry

## Admin SDK standards

Initialize Firebase Admin once at module scope:

```ts
import { initializeApp, getApps } from 'firebase-admin/app';

if (!getApps().length) {
  initializeApp();
}
```

Use Admin SDK only in trusted backend code. Do not mirror Admin SDK access assumptions into client code or Firestore rules.

Prefer shared collection path helpers when the repository has them:

```ts
const ref = db.collection(collections.vehicles(uid)).doc(vehicleId);
```

If there is no helper, keep path construction deterministic and centralized rather than scattering string paths across handlers.

## Custom claims and RBAC

Set custom claims only from trusted backend flows:

```ts
await getAuth().setCustomUserClaims(uid, { role: 'professional' });
```

When claims change:

- update any affected Firestore rules
- document how clients refresh ID tokens
- keep claim payloads small
- avoid using custom claims for fast-changing state

## Firestore backend patterns

### Idempotent writes

Use deterministic document IDs for external IDs, request IDs, and retryable workflows:

```ts
await db.collection('transactions').doc(`txn-${externalId}`).set(data, { merge: true });
```

### Firestore cache

For expensive provider or AI calls:

```ts
const cacheKey = `${code}-${make}-${model}-${year}`.toLowerCase();
const cacheRef = db.collection('dtcAnalysisCache').doc(cacheKey);
const cached = await cacheRef.get();

if (cached.exists) {
  return cached.data();
}

const result = await computeExpensiveResult();
await cacheRef.set({ ...result, createdAt: FieldValue.serverTimestamp() });
return result;
```

Always define cache invalidation assumptions.

### Batch writes

Use batches for catalog sync and related multi-document updates:

```ts
const batch = db.batch();
batch.set(ref, data, { merge: true });
await batch.commit();
```

Keep batch size under Firestore limits and split large imports.

## Emulator and local development

Use existing emulator commands and environment variables. Common variables:

```bash
FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080
FIREBASE_STORAGE_EMULATOR_HOST=127.0.0.1:9199
```

Do not hardcode emulator hosts in production code. Read environment configuration through the repository's existing config layer.

## Testing expectations

Prefer the repository's existing runner:

- Vitest in Turbo/pnpm TypeScript projects
- Jest in Nx projects when the workspace is configured that way
- Firebase emulator integration tests for function behavior that depends on Auth, Firestore, or Storage

Test:

- unauthenticated denial
- invalid payload denial
- not-found and permission-denied paths
- successful path
- idempotent retry behavior where relevant
- Firestore side effects

## Refusal and boundary rules

- Do not add long-lived service account keys to source code or workflow files.
- Do not use broad `any` request payloads when a schema can be defined.
- Do not swallow provider errors and return success-shaped responses.
- Do not write functions that require client-side Firestore rules to enforce backend-only invariants.
- Do not create v1 functions for new code without an explicit compatibility reason.
- Do not claim emulator validation passed unless the existing validation command ran successfully.

## Supplemental guidance

Use the companion checklist in [DELIVERY-CHECKLIST.md](./DELIVERY-CHECKLIST.md) before delivery.
