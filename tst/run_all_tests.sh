#!/usr/bin/env bash
# runs all unit tests

# Unit tests
logfile="./report/output.log"
if [[ -n "$1" ]]; then
        echo "" > "$logfile"
    if [[ -n "$2" ]]; then
        echo "=====running validation (base) tests ====" | tee -a  "$logfile"
        bats --output "./report" val_base*.bats | tee -a "$logfile"
        echo "=====running validation tests ====" | tee -a "$logfile"
        bats --output "./report" val_error.bats | tee -a "$logfile"
        bats --output "./report" val_normal.bats | tee -a "$logfile"
        echo "=====running git_operation tests ====" | tee -a  "$logfile"
        bats --output "./report" git_operations*.bats | tee -a "$logfile"
        echo "=====running log tests ====" | tee -a "$logfile"
        bats --output "./report" log*.bats | tee -a "$logfile"
        echo "=====running ini tests ====" | tee -a "$logfile"
        bats --output "./report" ini*.bats | tee -a "$logfile"
        bats --output "./report" . | tee "$logfile"
    else
        for file in *.bats; do
            echo "testing file: $file" | tee -a  "$logfile"
            bats --output "./report" "$file" | tee -a "$logfile"
        done
        
    fi
else
    #bats  --formatter pretty --output "./report" .
     for file in *.bats; do
            echo "testing file: $file"
            bats --output "./report" "$file"
        done
fi

