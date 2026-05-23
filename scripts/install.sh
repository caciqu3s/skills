#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/install.sh <copilot|claude> <package-path>
  ./scripts/install.sh <copilot|claude> --all

Examples:
  ./scripts/install.sh copilot engineering/architecture-gcp-mvp-standards
  ./scripts/install.sh claude --all
EOF
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

agent="$1"
target="$2"

case "$agent" in
  copilot)
    install_dir="${HOME}/.copilot/skills"
    ;;
  claude)
    install_dir="${HOME}/.claude/skills"
    ;;
  *)
    usage
    exit 1
    ;;
esac

mkdir -p "$install_dir"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

install_skill() {
  local package_path="$1"
  local skills_dir="${repo_root}/${package_path}/skills"
  if [[ ! -d "$skills_dir" ]]; then
    echo "Skill package not found: ${package_path}" >&2
    exit 1
  fi

  find "$skills_dir" -mindepth 1 -maxdepth 1 -type d | while IFS= read -r skill_path; do
    skill_name="$(basename "$skill_path")"
    rm -rf "${install_dir:?}/${skill_name}"
    cp -R "$skill_path" "$install_dir/"
    echo "Installed ${skill_name} -> ${install_dir}/${skill_name}"
  done
}

if [[ "$target" == "--all" ]]; then
  install_skill "engineering/architecture-gcp-mvp-standards"
  install_skill "engineering/angular-firebase-spa"
  install_skill "engineering/firebase-functions-api"
  install_skill "engineering/firestore-security-rules"
  install_skill "engineering/terraform-gcp-iac"
else
  install_skill "$target"
fi
