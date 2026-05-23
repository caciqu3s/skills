# Architecture definition delivery checklist

Use this checklist when applying the `architecture-gcp-mvp-standards` skill.

## Discovery

- Confirm whether the repository already has architecture, cloud, or framework constraints.
- Identify whether the product is frontend-only, API-only, SPA + API, or SPA + API + async workers.
- Identify whether the main workload is CRUD, workflow automation, document-centric, event-driven, or reporting-heavy.
- Confirm user authentication needs.
- Confirm file upload, export, webhook, and scheduled-job requirements.
- Confirm expected traffic pattern and whether cold starts are acceptable.
- Confirm whether there are enterprise constraints that override GCP/Firebase defaults.

## Stack selection

- Backend is TypeScript unless the user explicitly overrides it.
- Express is chosen for a small/simple HTTP service.
- NestJS is chosen for a mature CRUD API, modular domain backend, or integration-heavy service.
- Frontend is Angular SPA.
- SSR is not included.
- Hosting target for SPA is Firebase Hosting unless a specific reason suggests otherwise.
- GitHub Actions is the default CI/CD system for all apps.

## Data and platform choices

- Cloud SQL PostgreSQL is chosen when the domain is relational and transactional.
- Firestore is chosen when document flexibility and low-ops iteration are the better fit.
- Cloud Storage is included when files or generated assets exist.
- Cloud Tasks is included when deferred or retryable HTTP work exists.
- Pub/Sub is included only when true event fan-out or async decoupling is needed.
- Secret Manager is included for secret storage.
- Cloud Run is the default compute platform for backend services.

## FinOps review

- The design prefers managed serverless services.
- Scale-to-zero opportunities are identified.
- Single-region deployment is the default.
- Always-on cost drivers are called out explicitly.
- Variable cost drivers are called out explicitly.
- The design avoids GKE and other expensive operational defaults unless justified.
- The architecture names the first scaling upgrades that should be deferred until traction exists.
- Budget and billing alert recommendations are included.

## SRE and observability

- The 4 golden signals are defined for each critical service.
- Dashboards are specified for frontend, API, database, and queueing components that exist.
- Alert policies are proposed for latency, error rate, availability, and saturation.
- Structured logging is included.
- Correlation IDs or request tracing are mentioned when the system crosses service boundaries.
- Logging cost awareness is mentioned when log volume may grow.

## CI/CD

- GitHub Actions workflows are defined for every app in scope.
- Pull request validation is included before merge.
- Build and test gates are defined before deployment jobs.
- Angular apps include GitHub Actions steps for build/test/deploy to Firebase Hosting.
- Express and NestJS apps include GitHub Actions steps for build/test/deploy to Cloud Run.
- GitHub Actions access to GCP prefers Workload Identity Federation over long-lived keys.
- Workflow structure stays simple and cost-conscious for MVP delivery.

## Delivery quality bar

- The architecture uses named GCP/Firebase services, not vague placeholders.
- The architecture explains why Express or NestJS was selected.
- The architecture explains why Cloud SQL or Firestore was selected.
- The architecture identifies environments and deployment targets.
- The architecture identifies GitHub Actions workflows for CI and CD.
- The architecture includes security and secrets handling guidance.
- The architecture includes an MVP-to-scale evolution path.
- The architecture lists assumptions, risks, and open questions.
- The architecture remains concrete, low-cost, and implementable.
