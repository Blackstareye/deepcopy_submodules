#!/usr/bin/env bats
# those are functionality tests

function setup() {
    load "/test_helper/bats-support/load"
    load "/test_helper/bats-asserts/load"
    echo "$(pwd)"
    load "test.conf"
    load "testhelper.sh"
    # change directoy to script directory 
    changeDir "$SCRIPT_PATH"
    # load libs
    load "log.sh"
    load "tst/stub/test_stub.sh"
    make_TMP_DIR $TMP_PATH
    echo "$TMP_PATH"
    make_TMP_DIR $LOG_PATH

    load "git_operations.sh"
    ERROR_L="${LOG_PATH:?}/error.log"
    INFO_L="${LOG_PATH:?}/info.log"
    init_log "$LOG_PATH"
    clear_logs
}


function teardown() {
    if [[ -d ${TMP_PATHJ} ]]; then
        /bin/rm  -rf ${TMP_PATH}    
    fi
}
# with base local sem_okay sem_okay
@test "set 1 remove_submodules - zero params: " {
    section_list=("foo" "bar")
    URL_ARR=("foo" "localhost")
    run remove_submodules
    assert_failure
    assert_output --partial "Error occured - Git Operation : Removing Task was not possible"
}
@test "set 2 remove_submodules - section list not there: " {
    #section_list=("foo" "bar")
    URL_ARR=("foo" "localhost")
    run remove_submodules  ${TMP_PATH}
    assert_failure
    assert_output --partial "Error occured - Git Operation : Removing Task was not possible"
}
@test "set 3 remove_submodules - more than one param" {
    section_list=("foo" "bar")
    URL_ARR=("foo","localhost")
    run remove_submodules  "${TMP_PATH}" "foo" "bar"
    assert_failure
    assert_output --partial "Error occured - Git Operation : Removing Task was not possible"
}
@test "set 4 remove_submodules - url set is empty" {
    section_list=("foo" "bar")
    URL_ARR=()
    run remove_submodules  "${TMP_PATH}" "foo" "bar"
    assert_failure
    assert_output --partial "Error occured - Git Operation : Removing Task was not possible"
}


@test "set 5 add_submodules_local - zero params: " {
    section_list=("foo" "bar")
    URL_ARR=("foo" "localhost")
    run add_submodules_local
    assert_failure
    assert_output --partial "Error occured - Git Operation : Adding (local) Task was not possible "
}
@test "set 6 add_submodules_local - section list not there: " {
    #section_list=("foo" "bar")
    URL_ARR=("foo" "localhost")
    run add_submodules_local  ${TMP_PATH}
    assert_success
    refute_output
}
@test "set 7 add_submodules_local - more than one param" {
    section_list=("foo" "bar")
    URL_ARR=("foo","localhost")
    run add_submodules_local  "${TMP_PATH}" "foo" "bar"
    assert_failure
    assert_output --partial "Error occured - Git Operation : Adding (local) Task was not possible "
}
@test "set 8 add_submodules_local - url set is empty" {
    section_list=("foo" "bar")
    URL_ARR=()
    run add_submodules_local  "${TMP_PATH}" "foo" "bar"
    assert_failure
    assert_output --partial "Error occured - Git Operation : Adding (local) Task was not possible "
}
@test "set 9 push_changes - zero params: " {
    section_list=("foo" "bar")
    URL_ARR=("foo" "localhost")
    run push_changes
    assert_failure
    assert_output --partial "Error occured - Git Operation : Push Task was not possible"
}
@test "set 10 push_changes - section list not there: " {
    #section_list=("foo" "bar")
    URL_ARR=("foo" "localhost")
    run push_changes  ${TMP_PATH}
    assert_success
    refute_output
}
@test "set 11 push_changes - more than one param" {
    section_list=("foo" "bar")
    URL_ARR=("foo","localhost")
    run push_changes  "${TMP_PATH}" "foo" "bar"
    assert_failure
    assert_output --partial "Error occured - Git Operation : Push Task was not possible"
}
@test "set 12  push_changes - url set is empty" {
    section_list=("foo" "bar")
    URL_ARR=()
    run push_changes  "${TMP_PATH}" "foo" "bar"
    assert_failure
    assert_output --partial "Error occured - Git Operation : Push Task was not possible"
}
@test "set 13 add_submodules_new_remote - zero params: " {
    section_list=("foo" "bar")
    URL_ARR=("foo" "localhost")
    run add_submodules_new_remote
    assert_failure
    assert_output --partial "Error occured - Git Operation : Adding Task was not possible"
}
@test "set 14 add_submodules_new_remote - section list not there: " {
    #section_list=("foo" "bar")
    URL_ARR=("foo" "localhost")
    run add_submodules_new_remote  ${TMP_PATH}
    assert_success
    refute_output
}
@test "set 15 add_submodules_new_remote - more than one param" {
    section_list=("foo" "bar")
    URL_ARR=("foo","localhost")
    run add_submodules_new_remote  "${TMP_PATH}" "foo" "bar"
    assert_failure
    assert_output --partial "Error occured - Git Operation : Adding Task was not possible"
}
@test "set 16  add_submodules_new_remote - url set is empty" {
    section_list=("foo" "bar")
    URL_ARR=()
    run add_submodules_new_remote  "${TMP_PATH}" "foo" "bar"
    assert_failure
    assert_output --partial "Error occured - Git Operation : Adding Task was not possible"
}
@test "set 17 clone repo remote - zero params: " {
    URL_ARR=("localhost" "localhost")
    target="${TMP_PATH}/temporino"
    run clone_remote 
    #run clone_remote  ${URL_ARR[0]} $target
    assert_failure
    assert_output --partial "Error occured - Git Operation : Clone Task was not possible"
}

@test "set 18 clone repo remote  - more than one param" {
    URL_ARR=("localhost" "localhost")
    target="${TMP_PATH}/temporino"
    run clone_remote "lorem" "ipsum" "set dolor"
    #run clone_remote  ${URL_ARR[0]} $target
    assert_failure
    assert_output --partial "Error occured - Git Operation : Clone Task was not possible"
}
@test "set 19 clone repo remote  - url set is empty" {
    section_list=("foo" "bar")
    URL_ARR=()
    run clone_remote  "localhost" "${TMP_PATH}"
    assert_success
    refute_output
}
