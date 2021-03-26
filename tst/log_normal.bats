#!/usr/bin/env bats
# those are functionality tests

#mkdir /tmp/log_tmp/



changeDir() {
# let cwd be the actual  directory
cd ${1}
CWD_PATH="$(pwd)"
}


make_TMP_DIR() {
    if [[ ! -d "${1}" ]]; then 
        mkdir -p ${1}
    fi
}

function setup() {
    load "/test_helper/bats-support/load"
    load "/test_helper/bats-asserts/load"
    load "test.conf"
    # change directoy to script directory 
    changeDir ${SCRIPT_PATH}
    # load libs
    load "log.sh"
    make_TMP_DIR ${LOG_PATH}

    declare -a PARAMS=()
    PARAMS+=("ERROR")
    PARAMS+=("TXT")
    # #LOG_PATH="${TMP_LOG_PATH}"
    ERROR_L="${LOG_PATH:?}/error.log"
    INFO_L="${LOG_PATH:?}/info.log"
    init_log "$LOG_PATH"
    clear_logs
}

 function teardown() {
     clear_logs
 }

@test "test if log files exist" {
    [[ -f "${ERROR_L}"  &&  -f "${INFO_L}" ]]
}

@test "test clean logs" {
    run cat ${ERROR_L}
    refute_output
    run cat ${INFO_L}
    refute_output
}
@test "Test normal use info" {
  info ${PARAMS[@]}
  run grep "${PARAMS[0]}" ${ERROR_L}
  # don't match
  refute_output
  run grep "${PARAMS[1]}" ${ERROR_L}
  # don't match
  refute_output
  run grep "${PARAMS[0]}" ${INFO_L}
  assert_output --partial ${PARAMS[0]}
  run grep "${PARAMS[1]}" ${INFO_L}
  assert_output --partial ${PARAMS[1]}
}
@test "Test normal use console" {
  run console ${PARAMS[@]}
  assert_output --partial ${PARAMS[@]}
}
@test "Test normal use error" {
  error ${PARAMS[@]}
  run grep "${PARAMS[0]}" ${INFO_L}
  # don't match
  refute_output
  run grep "${PARAMS[1]}" ${INFO_L}
  # don't match
  refute_output
  run grep "${PARAMS[0]}" ${ERROR_L}
  assert_output --partial ${PARAMS[0]}
  run grep "${PARAMS[1]}" ${ERROR_L}
  assert_output --partial ${PARAMS[1]}
}
@test "Test normal use console exit" {
    run console_exit ${PARAMS[1]}
    assert_output --partial ${PARAMS[1]}
    assert_failure
}
