#!/usr/bin/env bash
# this is the caller for manual testing of the validation caller

source "log.sh"
LOG_PATH="/tmp/log_caller_tmp"
mkdir -p ${LOG_PATH}

init_log $LOG_PATH
clear_logs

source "validation.sh"
source "tst/validation_test_set.sh"

VALIDATION="true"
TEST_CONNECTIONS=""
    declare -a firstcall_check=("true" "${HTTPS_syn_sucess[0]}")
    declare -a secondcall_check=("false" "${HTTP_syn_faulty[0]}")
#plausi_check "remote" "localhost"
# shellcheck disable=SC2154
plausi_check "${secondcall_check[1]}"