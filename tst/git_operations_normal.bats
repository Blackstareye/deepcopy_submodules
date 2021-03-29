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
@test "set remove_submodules: " {
    section_list=("foo" "bar")
    URL_ARR=("foo","localhost")
    run remove_submodules  ${TMP_PATH}
    assert_success
    refute_output 
}
@test "set add_submodules_new_remote: " {
    section_list=("abc" "def")
    URL_ARR=("foo" "localhost")
    for url in "${section_list[@]}"; do
        mkdir -p ${TMP_PATH}/$url
    done
    run add_submodules_new_remote  ${TMP_PATH}
    assert_success
    refute_output 
    /bin/rm  -rf ${TMP_PATH}
}
@test "set add_submodules_local: " {
    section_list=("abc" "def")
    URL_ARR=("foo" "localhost")
    for url in "${section_list[@]}"; do
        mkdir -p ${TMP_PATH}/$url
    done
    run add_submodules_local  ${TMP_PATH}
    assert_success
    refute_output 
    /bin/rm  -rf ${TMP_PATH}
}
@test "set push_changes: " {
    section_list=("abc" "def")
    BASE_PATH="main_repo"
    URL_ARR=("foo" "localhost")
    run push_changes  ${TMP_PATH}
    assert_success
    refute_output 
}
# with base local sem_okay sem_okay
@test "set check if stub works: " {
    # NOTE source instead of load, arrays have problems with load
    run test_foo foo 
    assert_success 
    assert_output --partial "successfully"
}
@test "set  check if git stub works: " {
    # NOTE source instead of load, arrays have problems with load
    run git remote foo "http://lorem/ipsum"
    assert_success 
}
@test "set  check if rm stub works: " {
    # NOTE source instead of load, arrays have problems with load
    file="abc.bar"
    touch $file
    run rm $file
    assert_success 
    [[ -f  $file ]]
    /bin/rm $file
    [[ ! -f  $file ]]
}
