#!/usr/bin/env bash
# Trigger eval for find-distributors. See eval/_lib/run.sh.
exec "$(dirname "$0")/../_lib/run.sh" find-distributors "$@"
