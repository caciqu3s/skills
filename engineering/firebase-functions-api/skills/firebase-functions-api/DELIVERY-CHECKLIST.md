# Firebase Functions API delivery checklist

Use this checklist when applying the `firebase-functions-api` skill.

## Discovery

- Trigger type is selected intentionally: callable, HTTP, scheduled, document, or pub/sub.
- Existing project style is identified: raw handler, Express, NestJS, tRPC, or another router.
- Auth requirement is explicit.
- Input and output contracts are explicit.
- Required Firestore, Auth, Storage, or external provider side effects are identified.
- Idempotency and retry behavior are defined for webhook, scheduled, and external-provider flows.

## Implementation

- New functions use Firebase Functions v2 imports.
- Admin SDK initializes once at module scope.
- Callable functions check `request.auth` before user data access.
- Inputs are validated before side effects.
- Callable errors use `HttpsError` with appropriate codes.
- Domain logic lives in services/helpers rather than large handlers.
- Firestore paths use shared helpers or centralized deterministic paths.
- External IDs use idempotent document keys when retries are possible.
- Cache behavior is documented when Firestore caching is introduced.
- Custom claims are set only from trusted backend flows.

## Local and tests

- Existing build/typecheck/test commands are used.
- Emulator variables are used only for local development.
- Tests cover unauthenticated, invalid input, denied, and success paths.
- Firestore/Auth/Storage-dependent behavior is validated with emulators when applicable.
- Shared types or client call sites are updated if the function contract changes.

## Security and delivery

- No service account keys or secrets are committed.
- No provider raw errors are exposed to clients.
- No broad `any` request payload remains where a schema is practical.
- Firestore rules are updated if client access assumptions changed.
- Deployment notes identify the target environment and `firebase deploy --only ...` scope.
