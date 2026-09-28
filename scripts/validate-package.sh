#!/usr/bin/env bash
set -euo pipefail

root="${1:-$(cd "$(dirname "$0")/.." && pwd)}"

required=(
  "SKILL.md"
  "README.md"
  "LICENSE"
  "references/platform-routing.md"
  "references/research-fast.md"
  "references/research-deep.md"
  "references/evidence-rules.md"
  "references/deliverable-contract.md"
  "scripts/install.sh"
  "visual-system/RULES.md"
  "visual-system/CATALOG.md"
  "visual-system/svg-spec.md"
  "visual-system/LICENSE"
)

for file in "${required[@]}"; do
  test -s "$root/$file" || { echo "missing: $file" >&2; exit 1; }
done

template_count="$(find "$root/visual-system/templates" -mindepth 2 -maxdepth 2 -name design.md | wc -l | tr -d ' ')"
preview_count="$(find "$root/visual-system/assets/styles" -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')"

test "$template_count" -eq 35 || { echo "expected 35 templates, found $template_count" >&2; exit 1; }
test "$preview_count" -eq 35 || { echo "expected 35 previews, found $preview_count" >&2; exit 1; }

grep -q 'PROTOCOL_VERSION: 4.2' "$root/SKILL.md"
grep -q '## Gate 1' "$root/SKILL.md"
grep -q '## Gate 2' "$root/SKILL.md"
grep -q '## Gate 3' "$root/SKILL.md"
grep -q '## Gate 4' "$root/SKILL.md"
grep -q 'company-industry-research-v4 / 4.2' "$root/SKILL.md"
grep -q '不得据此推断画板可选' "$root/SKILL.md"
grep -q '正文结构”只定义报告文字章节' "$root/references/research-fast.md"
grep -q '非空总览画板' "$root/SKILL.md"
grep -q '画板 token' "$root/references/platform-routing.md"
grep -q '空白白板' "$root/references/deliverable-contract.md"
bash -n "$root/scripts/install.sh"

if find "$root" -mindepth 2 -name SKILL.md | grep -q .; then
  echo "nested SKILL.md found" >&2
  exit 1
fi

if find "$root" -name '.DS_Store' -o -name '__pycache__' | grep -q .; then
  echo "system artifacts found" >&2
  exit 1
fi

echo "package validation passed: $template_count templates, $preview_count previews"
