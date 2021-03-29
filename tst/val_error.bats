#!/usr/bin/env bats
# those are functionality tests

function setup() {
    load "/test_helper/bats-support/load"
    load "/test_helper/bats-asserts/load"
    load "test.conf"
    load "testhelper.sh"
    # change directoy to script directory 
    changeDir "$SCRIPT_PATH"
    # load libs
    load "log.sh"
    load "validation.sh"
    make_TMP_DIR $TMP_PATH
    make_TMP_DIR $LOG_PATH

    ERROR_L="${LOG_PATH:?}/error.log"
    INFO_L="${LOG_PATH:?}/info.log"
    init_log "$LOG_PATH"
    clear_logs
}

# with base remote sem_okay sem_okay
@test "null params" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    run plausi_check 
    assert_failure
    echo ${firstcall_check[*]}
    assert_output --partial "Invalid First Param. Param needs to be 'local', 'ssh' or 'remote'"
}
# with base remote sem_okay sem_okay
@test "one param url only" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("unknown" "remote")
    run plausi_check "remote"
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
}

# with base remote sem_okay sem_okay
@test "four params" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("true" "${HTTPS_sem_sucess[0]}")
    declare -a secondcall_check=("true" "${HTTPS_sem_sucess[1]}")
    run plausi_check "remote" "${firstcall_check[0]}" "abc" "three" #"${HTTPS_sem_sucess[1]}" 
    assert_failure
    assert_output --partial "INVALID VALIDATOR PARAM SIZE > 3"
}



function teardown() {
     clear_logs
}
