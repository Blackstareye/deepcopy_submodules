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
@test "1: (normal) one param" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("true" "${HTTPS_sem_sucess[0]}")
    declare -a secondcall_check=("true" "${HTTPS_sem_sucess[1]}")
    run plausi_check "remote" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    assert_equal "${output}" "${firstcall_check[*]}"
}
# with base remote sem_okay sem_okay
@test "2: (normal) two params" {
    # NOTE source instead of load, arrays have problems with load
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("true" "${HTTPS_sem_sucess[0]}")
    declare -a secondcall_check=("true" "${HTTPS_sem_sucess[1]}")
    run plausi_check "remote" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}

# with base remote sem_okay sem_okay
@test "3: one param base val:true test_con:true - con false" {
    # NOTE source instead of load, arrays have problems with load
    TEST_CONNECTIONS="false"
    VALIDATION="true"
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("true" "${HTTPS_syn_sucess[1]}")
    declare -a secondcall_check=("true" "${HTTPS_syn_sucess[1]}")
    run plausi_check "remote" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
}
# with base remote sem_okay sem_okay
@test "4: one param base val:true test_con:true - val false" {
    # NOTE source instead of load, arrays have problems with load
    TEST_CONNECTIONS="true"
    VALIDATION="false"
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("true" "${HTTPS_syn_faulty[1]}")
    declare -a secondcall_check=("true" "${HTTPS_syn_sucess[1]}")
    run plausi_check "remote" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
}


# with base remote sem_okay sem_okay
@test "5: two param base val:true test_con:true - con false" {
    # NOTE source instead of load, arrays have problems with load
    TEST_CONNECTIONS="false"
    VALIDATION="true"
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("true" "${SSH_syn_sucess[0]}")
    declare -a secondcall_check=("true" "${HTTPS_sem_sucess[3]}")
    run plausi_check "ssh" "${firstcall_check[1]}" #"${HTTPS_sem_sucess[1]}" 
    assert_success
    echo ${firstcall_check[*]}
    assert_equal "${output}" "${firstcall_check[*]}"
    run plausi_check "${secondcall_check[1]}" 
    assert_success
    assert_equal "${output[*]}" "${secondcall_check[*]}"
}
# with base remote sem_okay sem_okay
@test "6: two param base val:true test_con:true - val false" {
    # NOTE source instead of load, arrays have problems with load
    TEST_CONNECTIONS="true"
    VALIDATION="false"
    source "tst/validation_test_set.sh"
    declare -a firstcall_check=("true" "${HTTPS_syn_faulty[0]}")
    declare -a secondcall_check=("true" "${SSH_syn_faulty[1]}")
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
