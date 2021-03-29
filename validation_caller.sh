#!/usr/bin/env bash
# this is the caller for manual testing of the validation caller

source "log.sh"
LOG_PATH="/tmp/log_caller_tmp"
mkdir -p ${LOG_PATH}

init_log $LOG_PATH
clear_logs

source "validation.sh"
source "tst/validation_test_set.sh"

echo ${HTTPS_sem_sucess[2]}
#plausi_check "ssh" "localhost"
#plausi_check "remote" "localhost"
plausi_check "remote" "${firstcall_check[0]}" "abc" "three"