#!/usr/bin/env bash
set -Eeuo pipefail

REPOSITORY="irisivy7421-ux/company-industry-research-skill"
REF="v4.2.3"
SKILL_DIR_NAME="company-industry-research-v4"
TARGET_DIR="${CODEX_HOME:-$HOME/.codex}/skills"

usage() {
  cat <<'EOF'
Usage: install.sh [--target <skills-directory>] [--ref <git-ref>]

Install the company-and-industry research Skill.

Options:
  --target  Parent directory where the Skill folder will be installed.
            Default: ${CODEX_HOME:-$HOME/.codex}/skills
  --ref     Git tag, branch, or commit to install. Default: v4.2.0
  -h, --help  Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET_DIR="${2:?missing value for --target}"
      shift 2
      ;;
    --ref)
      REF="${2:?missing value for --ref}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

for command in curl unzip mktemp; do
  command -v "$command" >/dev/null || {
    printf 'Missing required command: %s\n' "$command" >&2
    exit 1
  }
done

work_dir="$(mktemp -d)"
destination="$TARGET_DIR/$SKILL_DIR_NAME"
backup=""

cleanup() {
  status="$1"
  if [[ "$status" -ne 0 && -n "$backup" && ! -e "$destination" && -e "$backup" ]]; then
    mv "$backup" "$destination"
  fi
  rm -rf "$work_dir"
  exit "$status"
}
trap 'cleanup $?' EXIT

archive="$work_dir/source.zip"
curl --fail --location --retry 2 --output "$archive" \
  "https://github.com/$REPOSITORY/archive/refs/tags/$REF.zip"
unzip -q "$archive" -d "$work_dir"

source_dir="$(find "$work_dir" -mindepth 1 -maxdepth 1 -type d -name 'company-industry-research-skill-*' -print -quit)"
[[ -n "$source_dir" && -s "$source_dir/SKILL.md" ]] || {
  printf 'Downloaded archive does not contain a valid Skill.\n' >&2
  exit 1
}

mkdir -p "$TARGET_DIR"
if [[ -e "$destination" ]]; then
  backup="${destination}.backup.$(date +%Y%m%d%H%M%S)"
  mv "$destination" "$backup"
fi
mv "$source_dir" "$destination"

printf 'Installed %s at %s\n' "$SKILL_DIR_NAME" "$destination"
if [[ -n "$backup" ]]; then
  printf 'Previous version kept at %s\n' "$backup"
fi
