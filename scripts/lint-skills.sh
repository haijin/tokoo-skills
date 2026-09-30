#!/usr/bin/env bash
# Lint SKILL.md frontmatter: required keys present and name matches its folder.
set -euo pipefail
cd "$(dirname "$0")/.."
status=0
for f in skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$f")")
  head -1 "$f" | grep -qx -- '---' || { echo "$f: missing frontmatter"; status=1; continue; }
  fm=$(awk 'NR==1{next} /^---$/{exit} {print}' "$f")
  for key in name description version; do
    echo "$fm" | grep -q "^$key:" || { echo "$f: missing '$key'"; status=1; }
  done
  name=$(echo "$fm" | sed -n 's/^name: *//p')
  [ "$name" = "$dir" ] || { echo "$f: name '$name' != folder '$dir'"; status=1; }
  desc_len=$(echo "$fm" | sed -n 's/^description: *//p' | wc -c)
  [ "$desc_len" -le 1024 ] || { echo "$f: description over 1024 chars ($desc_len)"; status=1; }
done
jq -e . .claude-plugin/plugin.json .claude-plugin/marketplace.json .mcp.json >/dev/null || status=1
for q in eval/*/queries.json; do jq -e '.queries | length > 0' "$q" >/dev/null || { echo "$q: bad"; status=1; }; done
[ $status -eq 0 ] && echo "lint ok"
exit $status
