#!/usr/bin/env bats
# those are functionality tests

#mkdir /tmp/log_tmp/



function setup() {
    load "/test_helper/bats-support/load"
    load "/test_helper/bats-asserts/load"
    load "test.conf"
    load "testhelper.sh"
    # change directoy to script directory 
    changeDir ${SCRIPT_PATH}
    # load libs
    load "log.sh"
    make_TMP_DIR ${LOG_PATH}

    # #LOG_PATH="${TMP_LOG_PATH}"
    ERROR_L="${LOG_PATH:?}/error.log"
    INFO_L="${LOG_PATH:?}/info.log"
}

function teardown() {
  [[ -d ${LOG_PATH}/ ]] && clear_logs
  echo ""
}



@test "no logpath given" {
     LOG_PATH=""
     run init_log
     [[ "$status" == 1 ]]
     assert_output --partial "no logging possible, given path is not a valid path:"

    run error "ERROR" "WAH"
    [[ "$status" == 1 ]]
    assert_output --partial "warning: logger not initialized. No logging possible."
    run info "INFO" "WAH"
    [[ "$status" == 1 ]]
    assert_output --partial "warning: logger not initialized. No logging possible."

    run console "Hello"
    [[ "$status" == 0 ]]
    assert_output --partial "Hello"

    run console_exit "Hello"
    [[ "$status" == 1 ]]
    assert_output --partial "Hello"
    
     run clear_logs
     [[ "$status" == 1 ]]
     refute_output
 }
 @test "logpath does not exist" {
   LOG_PATH="HAKJHSA"
     run init_log
     [[ "$status" == 1 ]]
     assert_output --partial "no logging possible, given path is not a valid path:"

    run error "ERROR" "WAH"
    [[ "$status" == 1 ]]
    assert_output --partial "warning: logger not initialized. No logging possible."

    run info "INFO" "WAH"
    [[ "$status" == 1 ]]
    assert_output --partial "warning: logger not initialized. No logging possible."

    run console "Hello"
    [[ "$status" == 0 ]]
    assert_output --partial "Hello"

    run console_exit "Hello"
    [[ "$status" == 1 ]]
    assert_output --partial "Hello"
    
     run clear_logs
     [[ "$status" == 1 ]]
     refute_output
 }
 
 @test "no init before use" {
    run error "ERROR" "WAH"
    
    [[ "$status" == 1 ]]
    assert_output --partial "warning: logger not initialized. No logging possible."

    run info "INFO" "WAH"
    [[ "$status" == 1 ]]
    assert_output --partial "warning: logger not initialized. No logging possible."

    run console "Hello"
    [[ "$status" == 0 ]]
    assert_output --partial "Hello"

    run console_exit "Hello"
    [[ "$status" == 1 ]]
    assert_output --partial "Hello"
    
     run clear_logs
     echo "$status"
     [[ "$status" == 1 ]]
     refute_output
 }
