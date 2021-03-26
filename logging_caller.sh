#!/usr/bin/env bash

source "log.sh"

LOG_PATH="/tmp/log_caller_tmp"
mkdir -p ${LOG_PATH}

init_log $LOG_PATH
clear_logs
error "TEST" "DIDI"
info "TEST" "DIDI"
