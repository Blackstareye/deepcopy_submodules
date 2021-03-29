#!/usr/bin/env bash
# caller for logger
source "config.conf"
if [[ "$DEBUG" == "true" ]]; then
    cd ${SCRIPT_PATH} || exit 1
else
    cd "${0%/*}" || exit 1
fi
source "log.sh"

LOG_PATH="/tmp/log_caller_tmp"
mkdir -p ${LOG_PATH}

init_log $LOG_PATH
clear_logs
error "TEST" "DIDI"
info "TEST" "DIDI"
clear_logs
echo "hello"