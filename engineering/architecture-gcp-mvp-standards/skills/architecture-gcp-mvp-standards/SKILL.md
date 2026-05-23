---
name: architecture-gcp-mvp-standards
description: Use this for architecture definition, solution planning, and technical design of new or evolving MVP software projects. Prefer TypeScript backends, Angular SPA frontends, GCP/Firebase-managed services, FinOps-first decisions, and built-in SRE observability standards.
---

# Architecture definition for low-cost MVPs on TypeScript, Angular, and GCP/Firebase

Use this skill when the user asks for solution architecture, implementation planning, platform selection, system design, MVP scoping, technical standards, or project blueprints.

This skill is intentionally opinionated.

The defaults in this skill are the standard path unless the user explicitly requests a different stack or there is a hard technical constraint that makes the default unreasonable.

## Mission

When defining a project architecture:

- prefer **TypeScript** across backend and frontend
- prefer **Express** for simple HTTP services
- prefer **NestJS** for mature APIs, complete CRUD platforms, modular domain backends, and systems expected to grow
- prefer **Angular SPA** for web frontends
- do **not** propose SSR, SSG, or hybrid rendering unless the user explicitly asks for it
- prefer **GCP and Firebase managed services** over self-hosted infrastructure
- optimize for **low-cost MVP delivery** first, while keeping an upgrade path to a more robust design
- require **SRE visibility from day one**, including dashboards, alerts, and the 4 golden signals

Do not produce vendor-neutral architecture when the user asked for architecture and did not request neutrality. Use the standards below as the primary blueprint.

## Core defaults

Unless the user explicitly overrides them, architecture plans should default to:

- **Backend language:** TypeScript
- **Simple backend framework:** Express
- **Established API framework:** NestJS
- **Frontend framework:** Angular
- **Frontend rendering model:** SPA only, no SSR
- **Primary cloud:** GCP
- **Primary app platform services:** Firebase Auth, Firebase Hosting, Cloud Run, Cloud SQL, Firestore, Cloud Storage, Pub/Sub, Cloud Tasks, Secret Manager, Cloud Logging, Cloud Monitoring
- **CI/CD standard:** GitHub Actions for all app build, test, quality, release, and deployment workflows
- **Observability stack:** Cloud Monitoring dashboards, alerting policies, uptime checks when applicable, structured logging, trace correlation when applicable
- **FinOps posture:** serverless-first, scale-to-zero when possible, single region first, minimal always-on infrastructure, simple managed services before complex clusters

## Required workflow

1. Inspect the repository or request for existing architecture constraints.
   - If the repo already uses a different stack, do not silently overwrite it.
   - Call out the mismatch and recommend whether to preserve or migrate.
2. Determine the product shape.
   - internal tool
   - CRUD line-of-business app
   - public API
   - event-driven workflow
   - content/admin portal
   - mobile-backed API
3. Decide the minimum viable topology.
   - frontend only
   - SPA + API
   - SPA + API + async workers
   - API only
   - event-driven backend
4. Choose the backend style.
   - use **Express** when the service is small and direct
   - use **NestJS** when the system needs modularity, governance, and scale in code organization
5. Choose the data platform using the decision rules below.
6. Apply FinOps guardrails before finalizing the architecture.
7. Define the CI/CD baseline with GitHub Actions workflows for build, test, quality gates, and deployment.
8. Define the SRE baseline: dashboards, alerts, golden signals, and operational ownership.
9. Deliver the architecture in a concrete format with named services, boundaries, deployment targets, and delivery workflows.

If critical product details are missing, ask focused questions about data consistency, expected traffic, auth model, async workloads, file storage, and reporting needs.

## Backend standards

### Default backend rule

All backend services should be planned in **TypeScript**.

Do not propose Python, Java, Go, C#, or Node without TypeScript unless the user explicitly requests a different runtime or the repository already mandates it.

### Use Express when

Use **Express** as the default for simple HTTP services, especially when most of the following are true:

- the service is a small MVP or thin BFF
- there are roughly **10 or fewer core endpoints**
- the domain model is shallow
- a single datastore is enough
- the auth model is straightforward
- background processing is limited or absent
- the team needs fast delivery with low framework overhead
- the service can be organized with a clean but lightweight folder structure

Typical Express use cases:

- landing-page backend
- webhook receiver
- lightweight BFF for Angular SPA
- simple internal tool API
- narrow MVP microservice

### Use NestJS when

Use **NestJS** for more established APIs and systems likely to evolve, especially when one or more of the following are true:

- the product is a **complete CRUD platform**
- the API has multiple bounded contexts or business modules
- strong DTO validation and consistent controller/service/module patterns are beneficial
- there will be role-based access control, guards, interceptors, pipes, or versioning
- there are **10+ endpoints**, growing workflows, or multiple integrations
- the project will likely add queues, schedulers, webhooks, admin modules, or reporting
- long-term maintainability is more important than minimal framework weight

Typical NestJS use cases:

- admin backoffice platforms
- SaaS CRUD applications
- multi-module APIs
- APIs with governance, validation, and layered architecture needs
- systems with background jobs and integration-heavy domains

### Backend deployment default

Prefer **Cloud Run** for backend services.

Default Cloud Run guidance:

- start with **min instances = 0** when cold starts are acceptable
- use a **single region** for MVP unless compliance or latency clearly requires more
- set CPU and memory conservatively
- keep concurrency intentional instead of unlimited guessing
- avoid GKE for MVP unless the user explicitly needs Kubernetes-level control

Do not default to GKE for MVP architecture.

## Frontend standards

### Angular rule

All web frontends should default to **Angular SPA**.

Required frontend standards:

- **SPA only**
- **no SSR**
- **no Next.js** or similar SSR-first recommendation unless explicitly requested
- use Angular routing with lazy-loaded feature areas when the app is more than a trivial shell
- keep state management as simple as possible at MVP stage; do not force NgRx unless the app has clear state complexity
- prefer standalone components and modern Angular patterns when compatible with the repository baseline

### Frontend hosting default

Prefer **Firebase Hosting** for Angular SPA delivery.

Use Firebase Hosting when:

- the frontend is a static SPA
- CDN-backed global delivery is useful
- cost and simplicity matter
- there is no SSR requirement

Consider Cloud Storage + CDN only when there is a specific operational reason.

## GCP and Firebase service selection rules

### Identity

Default to **Firebase Authentication** for MVP user authentication unless enterprise SSO or strict corporate IAM integration changes the decision.

Use Firebase Auth for:

- email/password
- Google login
- common social auth
- low-friction SPA authentication

If enterprise workforce auth is the main use case, call out whether Identity Platform or external IdP integration is needed.

### Relational data

Default to **Cloud SQL for PostgreSQL** when the product has:

- strong relational data
- multi-table CRUD workflows
- reporting requirements
- transactional consistency needs
- admin/backoffice behavior
- moderate but conventional business data models

For MVP cost control:

- start with the smallest viable instance
- use a single region
- avoid read replicas until justified
- explicitly mention connection pooling strategy for Cloud Run

### Document and flexible data

Default to **Firestore** when the product benefits from:

- schemaless or evolving document structures
- direct frontend-friendly document access patterns
- simple user-scoped data
- fast MVP iteration with low operational overhead

Do not choose Firestore automatically for relational admin-heavy CRUD when Cloud SQL is the better fit.

### Files and assets

Use **Cloud Storage** for uploads, reports, exports, and generated assets.

### Background work

Use:

- **Cloud Tasks** for deferred HTTP work, retries, and operational workflows requiring controlled delivery
- **Pub/Sub** for event-driven fan-out and asynchronous decoupling between services
- **Cloud Scheduler** for cron-like triggers

Do not introduce Kafka, RabbitMQ, or self-managed brokers for MVP unless explicitly required.

### Secrets and config

Use **Secret Manager** for secrets.

Do not place secrets in source control, environment sample files with real values, or architecture diagrams as plain text.

## MVP topology defaults

### Default full-stack MVP

For a typical business MVP, prefer this reference architecture:

- **Angular SPA** on Firebase Hosting
- **TypeScript API** on Cloud Run
- **Firebase Auth** for authentication
- **Cloud SQL PostgreSQL** for transactional business data
- **Cloud Storage** for file uploads and generated documents
- **Secret Manager** for sensitive configuration
- **Cloud Monitoring + Cloud Logging** for observability

### Document-centric MVP

For lightweight products with user-scoped or flexible data:

- Angular SPA on Firebase Hosting
- Express or NestJS API on Cloud Run
- Firebase Auth
- Firestore
- Cloud Storage when file upload exists
- Cloud Monitoring and Logging

### Async workflow MVP

For systems with retries, imports, webhooks, or background processing:

- Angular SPA on Firebase Hosting if a web app exists
- NestJS API on Cloud Run
- Cloud Tasks for command-style background jobs
- Pub/Sub for event-driven fan-out when needed
- Cloud SQL or Firestore based on data model
- Cloud Monitoring dashboards and alerts for worker latency, queue depth, and failures

## FinOps standards

Every architecture produced with this skill must explicitly include low-cost guidance.

### Required FinOps posture

- prefer **managed serverless services** over clusters and self-hosted infrastructure
- prefer **scale-to-zero** when acceptable
- prefer **single-region deployment** first
- avoid multi-region, replicas, or HA tiers unless the business case justifies them
- avoid GKE, Memorystore, and complex networking unless clearly needed
- keep the first version small enough that monthly cost can be reasoned about service-by-service
- identify the top likely cost drivers in the design
- recommend budgets and alerts in GCP from the start

### FinOps review checklist inside every architecture

Always call out:

- likely always-on costs
- variable cost drivers such as database size, egress, invocations, storage, and logging volume
- where scale-to-zero applies and where it does not
- the first components to optimize if usage grows
- which later upgrades should be deferred until there is evidence

### Anti-patterns for MVP cost

Do not default to:

- GKE
- multi-region active-active
- always-on VM fleets
- separate services for every tiny domain without need
- managed Redis for a feature that can wait
- premium networking or enterprise add-ons with no proven demand

## SRE and observability standards

Every architecture must include an explicit observability section.

### Mandatory golden signals

Define how the solution will measure the **4 golden signals** for each user-facing service:

- **Latency**
- **Traffic**
- **Errors**
- **Saturation**

### Minimum dashboard requirements

At minimum, require dashboards for:

- Cloud Run request count
- Cloud Run latency, including p50 and p95 when available
- HTTP error rate, split at least by 4xx and 5xx classes
- container CPU and memory utilization
- concurrency or instance pressure for Cloud Run
- database CPU/storage/connections for Cloud SQL when used
- Firestore read/write/error activity when used
- Cloud Tasks queue depth, dispatch latency, and failure count when used
- Pub/Sub undelivered messages and oldest unacked age when used
- frontend uptime and core user journey availability where applicable

### Minimum alert expectations

Each architecture should propose starting alerts such as:

- sustained 5xx rate above an agreed threshold
- latency degradation above an agreed threshold
- service unavailable or uptime-check failure
- database CPU or connection exhaustion risk
- queue backlog growth beyond normal operating bounds
- error bursts in critical background jobs

Do not leave alerts as a vague future concern.

### Logging and tracing rules

- use **structured JSON logging** in backend services
- include correlation IDs when requests cross service boundaries
- connect logs, metrics, and traces when practical
- define log-retention awareness because logging cost can grow quickly

## CI/CD standards

Every architecture must define **GitHub Actions** as the standard mechanism for CI/CD operations across all apps.

### Mandatory GitHub Actions rule

- use **GitHub Actions** for all app CI/CD pipelines
- do not default to manual-only deployments
- do not default to alternative CI systems unless the user or repository explicitly requires them
- keep workflows simple, reviewable, and cost-conscious

### Minimum CI expectations

For every app, architecture outputs should include GitHub Actions workflows for:

- dependency installation with reproducible lockfile usage
- linting and static quality checks when applicable
- unit and integration test execution appropriate to the app
- build/package validation for deployable artifacts
- pull request validation before merge

### Minimum CD expectations

For every deployable app, architecture outputs should include GitHub Actions workflows for:

- deployment to the target platform after required checks pass
- environment-aware deployment separation such as dev and prod when those environments exist
- secret consumption through GitHub Actions secrets or, preferably, short-lived cloud federation
- rollback or redeploy guidance appropriate to the platform

### Preferred GitHub Actions delivery patterns

- prefer **Workload Identity Federation** for GitHub Actions access to GCP
- avoid long-lived service account keys unless the user explicitly accepts that trade-off
- use path filters or reusable workflows when multiple apps live in the same repository
- require build/test gates before deploy jobs
- separate CI validation from deployment approval concerns when production risk justifies it
- keep Angular, backend, and infrastructure workflows explicit instead of hiding critical release logic

### App-specific defaults

- **Angular apps:** GitHub Actions should run install, lint, test, build, and deploy to Firebase Hosting
- **Express apps:** GitHub Actions should run install, lint, test, build, containerize when applicable, and deploy to Cloud Run
- **NestJS apps:** GitHub Actions should run install, lint, test, build, and deploy to Cloud Run, with migration/release steps called out when relevant

### FinOps guidance for CI/CD

- avoid wasteful workflows that run every expensive job on every change when path-based or reusable workflows can reduce cost
- cache dependencies intentionally, but do not create opaque pipelines that are hard to debug
- keep artifact retention and log retention aligned with MVP cost discipline
- prefer a small number of clear workflows over a large fragmented pipeline estate

## Security and delivery guardrails

- prefer private service-to-service access where feasible
- use least-privilege IAM
- keep secrets in Secret Manager
- define environments simply: usually dev and prod first; add staging only when justified
- keep CI/CD lightweight, implemented with GitHub Actions, and compatible with GCP/Firebase deployment targets
- avoid over-engineered network segmentation for MVP without a concrete requirement

## Architecture output contract

When this skill is used, the resulting architecture definition should usually include:

1. system context and key user journeys
2. chosen stack with explicit justification
3. frontend architecture
4. backend architecture
5. data architecture
6. integration and async architecture
7. deployment topology on GCP/Firebase
8. CI/CD architecture with GitHub Actions workflows per app
9. security and secrets approach
10. FinOps considerations and expected cost drivers
11. SRE dashboard and alert requirements
12. evolution path from MVP to scale-up
13. explicit assumptions, risks, and open questions

The output should name real services, not generic placeholders like “cloud database” or “message queue,” unless the user asked for vendor neutrality.

## Refusal and boundary rules

- Do not propose SSR for Angular web apps unless the user explicitly asks for it.
- Do not recommend a non-TypeScript backend by default.
- Do not default to Kubernetes for MVP.
- Do not omit GitHub Actions from app CI/CD planning unless the user explicitly requires another CI/CD system.
- Do not omit observability, dashboards, or alerts from architecture outputs.
- Do not ignore cost implications when selecting services.
- Do not introduce unnecessary infrastructure just to appear enterprise-ready.
- Do not pretend Firestore and Cloud SQL are interchangeable; explain the trade-off.
- Do not produce abstract architecture with no named GCP/Firebase services when the task is concrete planning.

## Companion checklist

Use [DELIVERY-CHECKLIST.md](./DELIVERY-CHECKLIST.md) to make sure each architecture definition is concrete, low-cost, and operationally reviewable.
