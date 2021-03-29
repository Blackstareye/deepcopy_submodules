#!/usr/bin/env bash
# caller for logger
source "config.conf"
if [[ "$DEBUG" == "true" ]]; then
    cd ${SCRIPT_PATH} || exit 1
else
    cd "${0%/*}" || exit 1
fi
source "log.sh"
LOG_PATH="/tmp/log_caller_tmp"
mkdir -p ${LOG_PATH}

init_log $LOG_PATH
clear_logs

source "git_operations.sh"
source "tst/stub/test_stub.sh"

tmp_folder="/tmp/tmp_a"
#section_list=("abc" "def")
#URL_ARR=("foo" "")
#mkdir -p $tmp_folder
#for url in "${section_list[@]}"; do
#    mkdir -p $tmp_folder/$url
#done
remove_submodules #$tmp_folder
#section_list=("abc" "def")
#add_submodules_new_remote $tmp_folder
section_list=()
#add_submodules_local $tmp_folder
#push_changes $tmp_folder
#/bin/rm -rf $tmp_folder
# testing