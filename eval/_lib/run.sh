#!/usr/bin/env bash
# Shared trigger eval for every skill. Each eval/<skill>/run.sh execs this.
#
# Usage: eval/<skill>/run.sh [train|validation|all] [runs]   (defaults: train, 3)
#
# Each query in eval/<skill>/queries.json goes through the Claude Code CLI.
# We read the stream-json transcript to see whether the Skill tool was
# invoked with our skill name. A query passes when its trigger rate matches
# should_trigger: > 50% of runs for positives, <= 50% for negatives.
#
# Safety: unlike some upstream examples we do NOT use
# --dangerously-skip-permissions. Only the Skill tool is allowed, and turns are
# capped. In -p mode, a tool that is not allowed is refused instead of
# prompting, so the run cannot touch the network, the shell or files, and it
# still records whether Skill fired. (Verify on your CLI version: capture one
# run with --output-format stream-json and check the Skill tool_use event.)
#
# Run from a directory where this plugin is installed, for example:
#   claude plugin marketplace add ./ && claude plugin install tokoo@tokoo

set -uo pipefail

SKILL="${1:?skill name required}"; shift
SPLIT="${1:-train}"
RUNS="${2:-3}"
DIR="$(cd "$(dirname "$0")/../$SKILL" && pwd)"
QUERIES="$DIR/queries.json"

case "$SPLIT" in train|validation|all) ;; *) echo "split must be train|validation|all" >&2; exit 2 ;; esac
command -v claude >/dev/null || { echo "claude CLI not on PATH" >&2; exit 1; }
command -v jq     >/dev/null || { echo "jq not on PATH" >&2; exit 1; }
[ -f "$QUERIES" ]           || { echo "$QUERIES not found" >&2; exit 1; }

triggered() {
  claude -p "$1" \
      --output-format stream-json --verbose \
      --allowedTools "Skill" --max-turns 2 \
      </dev/null 2>/dev/null \
    | jq --slurp -e --arg skill "$SKILL" '
        any(.[]; .type == "assistant"
          and any(.message.content[]?;
                .type == "tool_use" and .name == "Skill"
                and ((.input.skill // .input.command // "") | test("(^|:)" + $skill + "$"))))' \
      >/dev/null
}

pass=0; fail=0
while IFS=$'\t' read -r id should query; do
  hits=0
  for _ in $(seq 1 "$RUNS"); do triggered "$query" && hits=$((hits + 1)); done
  if [ "$should" = "true" ]; then ok=$(( hits * 2 > RUNS )); else ok=$(( hits * 2 <= RUNS )); fi
  if [ "$ok" -eq 1 ]; then pass=$((pass + 1)); mark=PASS; else fail=$((fail + 1)); mark=FAIL; fi
  printf '%s %-4s should=%-5s %d/%d  %s\n' "$mark" "$id" "$should" "$hits" "$RUNS" "$query"
done < <(jq -r --arg split "$SPLIT" \
  '.queries[] | select($split == "all" or .split == $split) | [.id, (.should_trigger|tostring), .query] | @tsv' \
  "$QUERIES")

echo "---"
echo "$SKILL [$SPLIT]: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
