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
    cp -r  "tst/testpackage/." $TMP_PATH/ 
    clear_logs
}


function teardown() {
    if [[ -d ${TMP_PATH} ]]; then
        /bin/rm  -rf ${TMP_PATH}    
    fi
}

# with base local sem_okay sem_okay
@test "set 1 remove_submodules: " {
        section_list=("tinysubproject")
    URL_ARR=("foo","localhost")
    # WARNING : does only work with a valid git repo in testpackage
    #mkdir -p "/tmp/tst/unit_test"
    skip
    run remove_submodules  ${TMP_PATH}/tinyproject
    assert_success
    refute_output 
}
@test "set 2 add_submodules_new_remote: " {
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
@test "set 3 add_submodules_local: " {
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
@test "set 4 push_changes: " {
    section_list=("abc" "def")
    BASE_PATH="main_repo"
    URL_ARR=("foo" "localhost")
    run push_changes  ${TMP_PATH}
    assert_success
    refute_output 
}
# with base local sem_okay sem_okay
@test "set 5 check if stub works: " {
    run test_foo foo 
    assert_success 
    assert_output --partial "successfully"
}
@test "set  6 check if git stub works: " {
    run git remote foo "http://lorem/ipsum"
    assert_success 
}
@test "set  7 check if rm stub works: " {
    file="abc.bar"
    touch $file
    run rm $file
    assert_success 
    [[ -f  $file ]]
    /bin/rm $file
    [[ ! -f  $file ]]
}

@test "set  8 Clone Repo: " {
    section_list=("abc" "def")
    target="${TMP_PATH}/temporino"
    URL_ARR=("https://github.com/Blackstareye/Random-Pokemon-Generator" "duh")
    run clone_remote  ${URL_ARR[0]} $target
    assert_success
    refute_output 
    echo $target
    [[ -d $target/ ]]
    [[ -f $target/.gitmodules ]]
    [[ -d $target/.git ]]
    [[ -f $target/README.md ]]
    rm -r $target
}
