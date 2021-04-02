#!/usr/bin/env bats
# those are functionality tests

function setup() {
    load "/test_helper/bats-support/load"
    load "/test_helper/bats-asserts/load"
    load "test.conf"
    load "testhelper.sh"
    load "validation_test_set.sh"
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


# with base local sem_okay sem_okay
@test "set base: local path_okay remote_sem_okay" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("true" "${PATH_sucess[2]}")
    declare -a secondcall_check=("true" "${HTTPS_sem_sucess[0]}")
    run plausi_check "local" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}
# BASE Input Paritioning
@test "set 1 : local, path_okay, faulty" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("true" "${PATH_sucess[2]}")
    declare -a secondcall_check=("false" "${HTTPS_syn_faulty[0]}")
    run plausi_check "local" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}
# BASE Input Paritioning
@test "set 2 : local, path_okay, syn_okay" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("true" "${PATH_sucess[2]}")
    declare -a secondcall_check=("false" "${HTTPS_syn_sucess[0]}")
    run plausi_check "local" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}
@test "set 3 : local, path_okay, remote_sem_okay" {
       # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("true" "${PATH_sucess[3]}")
    declare -a secondcall_check=("true" "${HTTPS_sem_sucess[0]}")
    run plausi_check "local" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}
@test "set 4 : faulty, path_okay, remote_sem_okay" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("true" "${PATH_sucess[2]}")
    declare -a secondcall_check=("true" "${HTTPS_sem_sucess[0]}")
    run plausi_check "loci" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_failure
    assert_output --partial "Invalid First Param. Param needs to be 'local', 'ssh' or 'remote'"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}
@test "set 5 : remote, path_okay, remote_sem_okay" {
           # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("false" "${PATH_sucess[2]}")
    declare -a secondcall_check=("true" "${HTTPS_sem_sucess[0]}")
    run plausi_check "remote" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}
@test "set 6 : local, not_okay, remote_sem_okay" {
           # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("false" "${PATH_faulty[2]}")
    declare -a secondcall_check=("true" "${HTTPS_sem_sucess[0]}")
    run plausi_check "remote" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}

function teardown() {
     clear_logs
}
