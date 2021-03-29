#!/usr/bin/env bats
# those are functionality tests

function setup() {
    load "/test_helper/bats-asserts/load"
    load "test.conf"
    load "testhelper.sh"
    load "validation_test_set.sh"
    # change directoy to script directory 
    changeDir "SCRIPT_PATH"
    # load libs
    load "log.sh"
    load "script_to_test.sh"
    make_TMP_DIR TMP_PATH
    make_TMP_DIR LOG_PATH

    ERROR_L="?/error.log"
    INFO_L="?/info.log"
    init_log "LOG_PATH"
    clear_logs
}

# with base remote sem_okay sem_okay
@test "set base: remote sem_okay sem_okay" {

}
# BASE Input Paritioning
@test "set 1 : remote, sem_okay, faulty" {
    
}
# BASE Input Paritioning
@test "set 2 : remote, sem_okay, syn_okay" {

}
@test "set 3 : local, sem_okay, sem_okay" {
    
}
@test "set 4 : remote, syn_okay, sem_okay" {
}
@test "set 5 : remote, faulty, syn_okay" {

}

# with base local sem_okay sem_okay
@test "set base: local path_okay remote_sem_okay" {

}
# BASE Input Paritioning
@test "set 1 : local, path_okay, faulty" {
    
}
# BASE Input Paritioning
@test "set 2 : local, path_okay, syn_okay" {

}
@test "set 3 : local, path_okay, remote_sem_okay" {
    
}
@test "set 4 : faulty, path_okay, remote_sem_okay" {
    
}
@test "set 5 : remote, path_okay, remote_sem_okay" {
}
@test "set 6 : local, not_okay, remote_sem_okay" {

}


function teardown() {
     clear_logs
}
