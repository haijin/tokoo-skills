#!/usr/bin/env bash
# Trigger eval for check-company-trade. See eval/_lib/run.sh.
exec "$(dirname "$0")/../_lib/run.sh" check-company-trade "$@"
