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

# with base ssh sem_okay_ssh sem_okay_ssh
@test "set base: ssh sem_okay_ssh sem_okay_ssh" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("unknown" "${SSH_sem_sucess[0]}")
    declare -a secondcall_check=("unknown" "${SSH_sem_sucess[1]}")
    run plausi_check "ssh" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}
# BASE Input Paritioning
@test "set 1 : ssh, sem_okay_https, sem_okay_ssh" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("unknown" "${HTTPS_sem_sucess[1]}")
    declare -a secondcall_check=("unknown" "${SSH_sem_sucess[0]}")
    run plausi_check "ssh" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}
@test "set 2: ssh faulty sem_okay_ssh" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("unknown" "${SSH_syn_faulty[2]}")
    declare -a secondcall_check=("unknown" "${SSH_sem_sucess[0]}")
    run plausi_check "ssh" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}
@test "set 3: local sem_okay_ssh sem_okay_ssh" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("false" "${SSH_sem_sucess[1]}")
    declare -a secondcall_check=("unknown" "${SSH_sem_sucess[0]}")
    run plausi_check "local" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}
@test "set 4: faulty sem_okay_ssh sem_okay_ssh" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("true" "${SSH_sem_sucess[2]}")
    declare -a secondcall_check=("unknown" "${SSH_sem_sucess[0]}")
    run plausi_check "ssaah" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_failure
    echo ${firstcall_check[*]}
    assert_output --partial "Invalid First Param. Param needs to be 'local', 'ssh' or 'remote'"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}
@test "set 5: ssh sem_okay_ssh faulty" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("unknown" "${SSH_sem_sucess[2]}")
    declare -a secondcall_check=("unknown" "${SSH_syn_faulty[0]}")
    run plausi_check "ssh" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}
@test "set 6: ssh sem_okay_ssh sem_okay_https" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("unknown" "${SSH_sem_sucess[2]}")
    declare -a secondcall_check=("true" "${HTTPS_sem_sucess[0]}")
    run plausi_check "ssh" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
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
