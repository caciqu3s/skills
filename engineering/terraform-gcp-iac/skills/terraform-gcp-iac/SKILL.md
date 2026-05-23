---
name: terraform-gcp-iac
description: Use this for infrastructure-related work in coding projects, including cloud resources, environments, deployment foundations, networking, IAM, data services, and platform setup. Prefer Terraform for infrastructure as code, default to GCP when no provider is specified, and produce production-minded Terraform structure, docs, and validation steps.
---

# Terraform-first infrastructure delivery with bootstrap support

Use this skill when the user asks for infrastructure, platform setup, deployment foundations, environments, cloud architecture, or infrastructure as code for an application or coding project.

Do **not** use this skill for app-only changes that do not require infrastructure.

## Mission

When infrastructure is part of the task:

- prefer Terraform over ad hoc shell scripts, console-only instructions, or provider-specific click paths
- allow a small, auditable bootstrap script when it is needed to create the prerequisites that let Terraform manage the rest safely
- default to **GCP-first** guidance unless the user or repository clearly points to another provider
- create infrastructure that is maintainable, reviewable, and safe to evolve
- generate the surrounding project structure and usage guidance, not just a single `main.tf`

Treat bootstrap work as a handoff into Terraform, not a replacement for Terraform-managed infrastructure.

If the repository already has an established IaC standard that is not Terraform, do not silently replace it. Call out the mismatch and ask before migrating.

## Required workflow

1. Determine whether the task truly includes infrastructure.
   - If not, do not force Terraform into the solution.
2. Inspect the repository for existing IaC, cloud, deployment, and environment conventions.
   - Look for Terraform, Terragrunt, Helm, Kubernetes manifests, GitHub Actions, Docker, Pulumi, CloudFormation, or deployment directories.
3. If the cloud provider is unspecified, assume **GCP**.
4. Before writing code, identify the minimum viable infrastructure shape:
    - environments needed
    - resources needed
    - networking assumptions
    - IAM and access boundaries
    - state management approach
    - secrets handling approach
    - whether a bootstrap phase is required before Terraform can run
5. If critical details are missing, ask focused questions. Examples:
    - Which environments are needed: dev, staging, production?
    - Should state use a remote GCS backend?
    - What GCP project IDs, regions, and naming conventions apply?
    - Are there existing shared networks, service accounts, or IAM constraints?
    - Should the skill create a new GCP project or attach to an existing one?
    - What GitHub organization, repository, and branch constraints should federated CI access trust?
6. When bootstrapping is required, split the solution into two explicit phases:
   - **bootstrap phase**: create prerequisites such as project selection or creation, API enablement, remote state storage, and GitHub Actions access foundations
   - **Terraform phase**: manage the durable infrastructure after backend and identity prerequisites exist
7. Produce Terraform that is ready to validate, easy to extend, and aligned with the repository.

## Bootstrap-first guidance

Use a bootstrap script only when Terraform cannot reasonably own the zero-to-one setup by itself. Typical examples:

- creating or selecting the initial GCP project
- linking billing, folder, or org placement inputs that cannot be assumed
- creating the GCS bucket for the Terraform backend before `terraform init`
- creating Workload Identity Federation or a narrowly scoped service account path for GitHub Actions
- enabling APIs required for the first Terraform apply

When you generate a bootstrap script:

- keep it short, readable, and idempotent where practical
- prefer `gcloud` commands with explicit flags over interactive console steps
- require all org-specific values as inputs instead of inventing them
- limit the script to prerequisite setup only
- hand off immediately to Terraform for the rest of the infrastructure

Do not generate a script-only infrastructure solution when Terraform can manage the target resources after bootstrapping.

## Default output contract

When implementing Terraform for a project, aim to provide most or all of these artifacts as appropriate:

- `bootstrap/` or a clearly named setup script when prerequisite setup is in scope
- `versions.tf` for Terraform and provider version constraints
- `providers.tf` for provider configuration
- `main.tf` for resource composition
- `variables.tf` with typed variables, descriptions, and validation where helpful
- `outputs.tf` with meaningful outputs and descriptions
- `locals.tf` when shared naming or labels improve clarity
- `backend.tf` or backend guidance when remote state is required
- `terraform.tfvars.example` or equivalent sample input when users need a starting point
- supporting documentation or usage notes if the repository lacks them

For larger solutions, prefer:

- `modules/` for reusable building blocks
- `environments/` or `live/` directories for environment-specific composition
- clear separation between reusable modules and instantiated environment stacks

For bootstrap-oriented requests, also provide usage notes that make the handoff clear:

- what must be run before `terraform init`
- which values the bootstrap step produces for backend and CI auth
- which values must be copied into Terraform variables, backend config, or GitHub secrets/settings

## GCP-first defaults

Unless instructed otherwise:

- use the `hashicorp/google` provider
- use `google-beta` only when required by the resource set
- parameterize `project_id`, `region`, and `zone` instead of hardcoding them
- prefer remote state guidance built around **GCS**
- use labels consistently for ownership, environment, and application metadata
- model IAM explicitly and follow least-privilege principles
- keep service enablement, networking, IAM, and workloads understandable as separate concerns
- assume a **single GCP project first** unless the user asks for separate environments, but keep naming and variables extensible to multi-environment layouts later
- prefer GitHub Actions access built around Workload Identity Federation or the narrowest viable non-key-based alternative
- if a bootstrap script must grant IAM, scope permissions to backend setup, API enablement, and the specific Terraform runner identity only

## Terraform quality bar

All Terraform authored with this skill should follow these standards:

- no hardcoded credentials, secrets, or tokens
- no placeholder resources that pretend the task is complete
- variables must be typed unless there is a strong reason not to
- resource names should be deterministic and convention-driven
- avoid giant monolithic files when module boundaries are obvious
- avoid unnecessary module abstraction for tiny one-off stacks
- outputs should reflect real integration points the app or operator needs
- document assumptions, especially for networking, DNS, IAM, and state
- preserve compatibility with existing repository patterns when they are sensible
- bootstrap scripts must not rely on broad owner/editor grants when narrower roles can be stated explicitly
- GitHub Actions guidance must identify the repo identity being trusted and the minimal roles required for state access and Terraform execution

## Validation expectations

When tools are available, validate Terraform changes with the appropriate commands for the repository, typically:

```bash
terraform fmt -check -recursive
terraform validate
terraform plan
```

If execution cannot happen, say exactly what remains to validate and why.

When bootstrap artifacts are added, also validate as appropriate:

- shell syntax or basic execution flow for generated bootstrap scripts
- that backend bucket naming, location, and versioning assumptions are explicit
- that IAM bindings and GitHub trust configuration align with the stated repository and branch assumptions

## Delivery format

When presenting the result, structure the response around:

1. what bootstrap prerequisites and Terraform infrastructure were added or changed
2. assumptions and defaults used
3. files created or updated
4. validation performed or still required
5. follow-up inputs the user should provide next

## Refusal and boundary rules

- Do not introduce Terraform when the task is clearly unrelated to infrastructure.
- Do not invent production values for domains, billing accounts, project IDs, CIDR ranges, or secrets.
- Do not silently destroy or replace an existing non-Terraform IaC standard.
- Do not claim infrastructure is production-ready if backend, IAM, secrets, and environment strategy are unresolved.
- Do not use long-lived GitHub Actions service account keys when federation or another safer short-lived mechanism is viable.
- Do not use a bootstrap script to manage resources that clearly belong in the steady-state Terraform layer.

## Supplemental guidance

Use the companion checklist in [DELIVERY-CHECKLIST.md](./DELIVERY-CHECKLIST.md) to ensure the generated Terraform is complete and reviewable.
