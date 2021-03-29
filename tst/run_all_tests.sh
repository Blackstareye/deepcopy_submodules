#!/usr/bin/env bash
# runs all unit tests

# Unit tests
logfile="./report/output.log"
if [[ -n "$1" ]]; then
    bats --output "./report" . | tee "$logfile"
else
    bats  --formatter pretty --output "./report" .
fi

