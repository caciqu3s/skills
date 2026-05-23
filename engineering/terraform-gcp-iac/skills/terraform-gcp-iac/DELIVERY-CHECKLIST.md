# Terraform IaC delivery checklist

Use this checklist when applying the `terraform-gcp-iac` skill.

## Discovery

- Confirm the task truly needs infrastructure work.
- Check whether the repository already contains IaC or deployment conventions.
- Identify the target environments.
- Identify the target GCP project, region, and network assumptions.
- Decide whether remote state is required and how it should be handled.
- Decide whether a bootstrap phase is required before Terraform can run.
- Confirm whether the default scope is a single GCP project or a multi-environment layout.
- Identify billing account, org/folder placement, and API enablement assumptions.
- Identify the GitHub organization, repository, and branch/tag conditions that CI access should trust.

## Bootstrap scope

When bootstrap work is needed, confirm the delivery includes only prerequisite setup such as:

- GCP project creation or selection
- billing and org/folder attachment inputs
- required API enablement
- GCS bucket creation for Terraform remote state
- versioning or retention settings for the state bucket when appropriate
- GitHub Actions identity setup, preferably with Workload Identity Federation
- least-privilege IAM for backend access and Terraform execution

Avoid expanding the bootstrap step into a script-only replacement for the Terraform layer.

## Baseline files

- `versions.tf`
- `providers.tf`
- `main.tf`
- `variables.tf`
- `outputs.tf`

Add these when needed:

- `bootstrap/` or a clearly named setup script
- `locals.tf`
- `backend.tf`
- `terraform.tfvars.example`
- `README` or usage notes
- `modules/*`
- `environments/*` or `live/*`

## Quality checks

- Variables are typed and described.
- Outputs are useful and described.
- Sensitive values are not hardcoded.
- IAM is explicit and least-privilege oriented.
- Naming is consistent.
- Labels are applied where appropriate.
- The layout fits the scale of the project.
- Bootstrap steps are explicit about required inputs and do not invent org-specific values.
- The backend bucket setup is documented clearly enough for `terraform init` to succeed afterward.
- GitHub Actions access does not depend on long-lived static keys unless the user explicitly requires it.
- CI trust boundaries name the repository and any branch/environment restrictions.
- Bootstrap artifacts clearly hand off to Terraform for steady-state management.

## Validation

- Run `terraform fmt -check -recursive` when Terraform is available.
- Run `terraform validate` when the configuration is complete enough.
- Run `terraform plan` when provider credentials and input values are available.
- Validate bootstrap scripts for shell syntax and obvious idempotency/safety issues when scripts are part of the delivery.
- Verify the documented backend bucket, identity, and IAM outputs are enough to complete the first Terraform initialization.
- If validation cannot run, report the missing prerequisites clearly.
