#!/usr/bin/env bash
# Trigger eval for tokoo. See eval/_lib/run.sh.
exec "$(dirname "$0")/../_lib/run.sh" tokoo "$@"
