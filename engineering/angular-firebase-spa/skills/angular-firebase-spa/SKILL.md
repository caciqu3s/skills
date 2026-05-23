---
name: angular-firebase-spa
description: Use this when building or changing Angular single-page applications backed by Firebase or GCP APIs. Prefer standalone components, signals, modern template control flow, Firebase modular SDK, functional guards/interceptors, lazy routes, and Firebase Hosting-friendly SPA delivery.
---

# Angular Firebase SPA delivery

Use this skill when implementing Angular SPA features, auth flows, route guards, HTTP interceptors, Firebase client integrations, or Angular frontend delivery for Firebase/GCP-backed applications.

Do **not** use this skill for SSR, Angular Universal, Next.js, or non-Angular frontends unless the task is explicitly migrating to this stack.

## Mission

When building Angular apps in this workspace:

- use modern Angular standalone APIs
- prefer signals for local component state
- use Firebase modular SDK only
- keep auth state, guards, interceptors, and role checks centralized
- lazy-load feature areas
- keep feature code organized and testable
- preserve Firebase Hosting SPA compatibility

The default frontend shape is Angular SPA, not SSR.

## Required workflow

1. Inspect the Angular baseline.
   - Angular version
   - standalone component usage
   - signals availability
   - routing style
   - Firebase initialization style
   - test runner and build scripts
2. Identify the feature boundary.
   - page/routed container
   - reusable component
   - service
   - guard or interceptor
   - Firebase client integration
3. Add or update shared types before duplicating interfaces locally.
4. Implement state with signals or RxJS according to existing patterns.
5. Keep auth and role behavior in core services/guards.
6. Use lazy routes for feature areas.
7. Update tests and validation commands that already exist in the repository.

If the app already uses an older Angular pattern, preserve compatibility but do not introduce new NgModules or compat Firebase APIs for new code.

## Angular standards

### Standalone components

New components should be standalone:

```ts
import { Component, computed, signal } from '@angular/core';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
})
export class DashboardComponent {
  readonly loading = signal(true);
  readonly data = signal<DashboardData | null>(null);
  readonly hasData = computed(() => this.data() !== null);
}
```

Do not introduce `NgModule` for new feature work.

### Template control flow

Prefer modern control flow:

```html
@if (loading()) {
  <app-loading-state />
} @else if (data(); as dashboard) {
  <app-dashboard-summary [data]="dashboard" />
} @else {
  <app-empty-state />
}

@for (item of items(); track item.id) {
  <app-item-card [item]="item" />
}
```

Do not add new `*ngIf` or `*ngFor` usage in modern Angular apps unless the repository baseline requires it.

### Feature structure

Prefer:

```text
src/app/
  core/
    guards/
    interceptors/
    services/
  features/
    feature-name/
      pages/
      components/
      services/
      feature-name.routes.ts
  shared/
    components/
    pipes/
    utils/
```

Keep routed containers thin. Put Firebase and HTTP behavior in services.

## Firebase client standards

Use the modular SDK:

```ts
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
```

Do not use `firebase/compat/*` for new code.

### Dependency injection

Use injection tokens or provider functions to keep Firebase dependencies testable:

```ts
import { InjectionToken } from '@angular/core';
import { Auth } from 'firebase/auth';

export const FIREBASE_AUTH = new InjectionToken<Auth>('Firebase Auth');
```

Wire Firebase providers in `app.config.ts`:

```ts
export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(withInterceptors([authInterceptor])),
    { provide: FIREBASE_AUTH, useFactory: () => getAuth(firebaseApp) },
  ],
};
```

### Auth service

Centralize Firebase Auth state. Expose a readiness signal or observable so guards do not race initial auth loading.

```ts
readonly user = signal<User | null>(null);
readonly ready = signal(false);

constructor(@Inject(FIREBASE_AUTH) private readonly auth: Auth) {
  onAuthStateChanged(this.auth, (user) => {
    this.user.set(user);
    this.ready.set(true);
  });
}
```

Do not call `onAuthStateChanged` independently in every component.

## Routing, guards, and roles

Use lazy routes:

```ts
export const routes: Routes = [
  {
    path: 'patient',
    canActivate: [authGuard, roleGuard(['PATIENT'])],
    loadChildren: () => import('./features/patient/patient.routes').then((m) => m.patientRoutes),
  },
];
```

Use functional guards:

```ts
export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);

  return auth.ready$.pipe(
    filter(Boolean),
    take(1),
    map(() => (auth.currentUser() ? true : router.createUrlTree(['/login']))),
  );
};
```

Role guards should read from a trusted auth service state or backend-verified claims. Do not trust route parameters or local storage for authorization.

## HTTP interceptor standards

Attach Firebase ID tokens through a functional interceptor:

```ts
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);

  return from(auth.getIdToken()).pipe(
    switchMap((token) => {
      if (!token) {
        return next(req);
      }

      return next(req.clone({
        setHeaders: { Authorization: `Bearer ${token}` },
      }));
    }),
  );
};
```

Do not store ID tokens in local storage.

## Firestore client standards

Use typed service methods instead of Firestore calls scattered across components:

```ts
async listVehicles(userId: string): Promise<Vehicle[]> {
  const ref = collection(this.db, `users/${userId}/vehicles`);
  const snapshot = await getDocs(query(ref, orderBy('createdAt', 'desc'), limit(50)));
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }) as Vehicle);
}
```

Prefer shared collection path helpers when the repository has them.

Use `serverTimestamp()` for server-owned timestamps:

```ts
await addDoc(ref, {
  ...input,
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
});
```

## UI and state rules

- Components should show loading, error, empty, and success states.
- Subscriptions must be cleaned up with `takeUntilDestroyed`, `async` pipe, or signal-friendly patterns.
- Avoid deeply nested smart components; move data access into services.
- Do not use NgRx by default for MVP-scale features unless the app already uses it or state complexity justifies it.

## Testing expectations

Use the repository's existing Angular test setup.

Prefer:

- `TestBed` with standalone imports
- `provideRouter([])` instead of deprecated router testing modules in modern apps
- mocked Firebase injection tokens
- service tests for Firestore/HTTP mapping logic
- component tests for loading/error/empty/success states

## Refusal and boundary rules

- Do not introduce SSR or App Hosting unless explicitly requested.
- Do not add new NgModules to modern standalone apps.
- Do not use Firebase compat APIs for new code.
- Do not duplicate shared interfaces when a monorepo shared-types package exists.
- Do not bypass route guards by hiding UI only; enforce backend and rules authorization too.
- Do not store secrets or long-lived tokens in Angular environment files.

## Supplemental guidance

Use the companion checklist in [DELIVERY-CHECKLIST.md](./DELIVERY-CHECKLIST.md) before delivery.
