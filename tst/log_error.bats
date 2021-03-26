#!/usr/bin/env bats

function setup() {
    load "/test_helper/bats-support/load"
    load "/test_helper/bats-asserts/load"
    load "/test_helper/bats-file/load"
    load "test.conf"
    # change directoy to script directory 
    changeDir
    # load libs
    load "log.sh"
    make_TMP_DIR

    declare -a PARAMS=()
    PARAMS+=("ERROR")
    PARAMS+=("TXT")
    # #LOG_PATH="${TMP_LOG_PATH}"
    ERROR_L="${LOG_PATH:?}/error.log"
    INFO_L="${LOG_PATH:?}/info.log"
    init_log "$LOG_PATH"
    clear_logs
}

@test "Test no logpath given" {
    run 
  [ "$status" -eq 1 ]
  [ "$output" = "foo: no such file 'nonexistent_filename'" ]
}
@test "Test no init before use" {
    run 
  [ "$status" -eq 1 ]
  [ "$output" = "foo: no such file 'nonexistent_filename'" ]
}
