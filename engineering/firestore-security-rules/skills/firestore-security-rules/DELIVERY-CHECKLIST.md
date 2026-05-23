# Firestore security rules delivery checklist

Use this checklist when applying the `firestore-security-rules` skill.

## Discovery

- Identify every Firestore collection and Storage path touched by the task.
- Identify whether each resource is user-scoped, role-scoped, public, server-only, append-only, or status-gated.
- Identify the authority source: `request.auth.uid`, custom claims, trusted profile documents, or immutable owner fields.
- Confirm whether Admin SDK or client SDK writes the data.

## Rule authoring

- Rules use `rules_version = '2';`.
- Helper functions are used for repeated auth, ownership, and role checks.
- Create and update validations are modeled separately.
- Owner, role, status, and ACL fields cannot be escalated by client updates.
- Server-only collections use `allow read, write: if false`.
- Append-only data blocks update and delete.
- Public/status-gated reads explicitly check allowed states.
- Storage writes validate auth, path ownership, size, and content type.

## Testing

- Rule tests use `@firebase/rules-unit-testing`.
- Tests run against the Firebase emulator.
- Fixture data is seeded with `withSecurityRulesDisabled`.
- Tests include both allowed and denied cases.
- Tests cover create, read, update, and delete for high-risk paths.
- Tests cover cross-user access denial.
- Tests cover update bypass attempts for owner, role, status, and sensitive fields.
- Test data is cleared between cases.

## Security review

- No `allow read, write: if true` remains in production rules.
- No admin or privileged behavior depends on client-writable fields.
- No broad catch-all match weakens specific rules.
- Rules align with application collection path helpers and backend write patterns.
- Any untested rule behavior is called out explicitly.
