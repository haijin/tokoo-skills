#!/usr/bin/env bash
# Trigger eval for find-importers. See eval/_lib/run.sh.
exec "$(dirname "$0")/../_lib/run.sh" find-importers "$@"
