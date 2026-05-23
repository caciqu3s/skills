# Angular Firebase SPA delivery checklist

Use this checklist when applying the `angular-firebase-spa` skill.

## Discovery

- Angular version and standalone support are identified.
- Firebase initialization style is identified.
- Existing auth service, guards, interceptors, and role handling are inspected.
- Shared types and collection path helpers are identified before adding local types.
- Existing build/test/lint commands are identified.

## Angular implementation

- New components are standalone.
- Component state uses signals when compatible with the app baseline.
- Templates use `@if` and `@for` in modern Angular apps.
- Feature code is organized under `core/`, `features/`, and `shared/` boundaries.
- Feature routes are lazy-loaded.
- Components include loading, error, empty, and success states.
- Subscriptions are cleaned up safely.

## Firebase integration

- New Firebase client code uses modular SDK imports.
- Firebase dependencies are injected through app providers or injection tokens.
- Auth state is centralized in a service.
- Guards wait for auth readiness before redirecting.
- Role checks use trusted service state or backend-verified claims.
- HTTP interceptor attaches fresh Firebase ID tokens without local storage.
- Firestore calls live in services, not directly in routed components.
- Server timestamps and shared collection path helpers are used when available.

## Security and delivery

- Frontend guards are not treated as the only authorization layer.
- Backend APIs or Firestore rules enforce the same access assumptions.
- No secrets or service account material are added to Angular environment files.
- Existing tests/builds are updated for changed behavior.
