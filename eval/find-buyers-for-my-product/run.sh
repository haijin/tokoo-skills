#!/usr/bin/env bash
# Trigger eval for find-buyers-for-my-product. See eval/_lib/run.sh.
exec "$(dirname "$0")/../_lib/run.sh" find-buyers-for-my-product "$@"
