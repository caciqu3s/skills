# Agent Skills

Claude-style skill packages for cross-agent reuse.

This repository packages two personal skills in the same broad structure used by Claude skills repositories:

- one folder per skill package
- a `.claude-plugin/plugin.json` manifest for Claude-compatible packaging
- a `skills/<skill-name>/` directory containing the actual skill files

## Included skills

| Domain | Skill | Purpose |
| --- | --- | --- |
| engineering | `architecture-gcp-mvp-standards` | Opinionated MVP architecture guidance for TypeScript, Angular, GCP, and Firebase |
| engineering | `angular-firebase-spa` | Angular SPA implementation guidance for standalone components, signals, Firebase Auth, guards, interceptors, and Firebase-backed frontends |
| engineering | `firebase-functions-api` | Firebase Functions v2 TypeScript API guidance for callable/HTTP handlers, Admin SDK, custom claims, emulators, and backend patterns |
| engineering | `firestore-security-rules` | Security-first Firestore and Storage rules authoring with emulator-backed tests |
| engineering | `terraform-gcp-iac` | Terraform-first GCP infrastructure delivery guidance |

## Repository layout

```text
engineering/
  architecture-gcp-mvp-standards/
    .claude-plugin/plugin.json
    README.md
    skills/architecture-gcp-mvp-standards/
      SKILL.md
      DELIVERY-CHECKLIST.md
  angular-firebase-spa/
    .claude-plugin/plugin.json
    README.md
    skills/angular-firebase-spa/
      SKILL.md
      DELIVERY-CHECKLIST.md
  firebase-functions-api/
    .claude-plugin/plugin.json
    README.md
    skills/firebase-functions-api/
      SKILL.md
      DELIVERY-CHECKLIST.md
  firestore-security-rules/
    .claude-plugin/plugin.json
    README.md
    skills/firestore-security-rules/
      SKILL.md
      DELIVERY-CHECKLIST.md
  terraform-gcp-iac/
    .claude-plugin/plugin.json
    README.md
    skills/terraform-gcp-iac/
      SKILL.md
      DELIVERY-CHECKLIST.md
scripts/
  install.sh
```

## Install

### Copilot CLI

Install one skill:

```bash
./scripts/install.sh copilot engineering/architecture-gcp-mvp-standards
```

Install all skills:

```bash
./scripts/install.sh copilot --all
```

### Claude Code

Install one skill:

```bash
./scripts/install.sh claude engineering/terraform-gcp-iac
```

Install all skills:

```bash
./scripts/install.sh claude --all
```

### Manual install

Copy the inner skill folder to the target agent's skills directory:

- Copilot CLI: `~/.copilot/skills/`
- Claude Code: `~/.claude/skills/`

Example:

```bash
cp -R engineering/terraform-gcp-iac/skills/terraform-gcp-iac ~/.copilot/skills/
cp -R engineering/terraform-gcp-iac/skills/terraform-gcp-iac ~/.claude/skills/
```

## Sharing

This is a normal git repository, so you can publish it to GitHub and share it like any Claude-style skills repo:

```bash
git remote add origin <your-repo-url>
git add .
git commit -m "Initial skills repository"
git push -u origin main
```

## License

MIT
