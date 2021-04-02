#!/usr/bin/env bash
# caller for logger
source "config.conf"
if [[ "$DEBUG" == "true" ]]; then
    cd ${SCRIPT_PATH} || exit 1
else
    cd "${0%/*}" || exit 1
fi
# shellcheck disable=1091
source "log.sh"
LOG_PATH="/tmp/log_caller_tmp"
mkdir -p ${LOG_PATH}

init_log $LOG_PATH
clear_logs

# shellcheck disable=1091
source "git_operations.sh"
# shellcheck disable=1091
source "tst/stub/test_stub.sh"

#tmp_folder="/tmp/tmp_a"
#section_list=("abc" "def")
#URL_ARR=("foo" "")
#mkdir -p $tmp_folder
#for url in "${section_list[@]}"; do
#    mkdir -p $tmp_folder/$url
#done
#remove_submodules #$tmp_folder
#section_list=("abc" "def")
#add_submodules_new_remote $tmp_folder
# section_list=()
#add_submodules_local $tmp_folder
#push_changes $tmp_folder
#/bin/rm -rf $tmp_folder
# testing
# section_list=("tinysubproject")
# URL_ARR=("foo","localhost")
# mkdir -p "/tmp/tst/unit_test"
# cp -r "tst/testpackage/." "/tmp/tst/unit_test/"
# remove_submodules  "/tmp/tst/unit_test/tinyproject"
# rm -r "/tmp/tst/unit_test/"
section_list=("abc" "def")
TMP_PATH="/tmp/tst/unit_testing/"
mkdir -p ${TMP_PATH} 
target="${TMP_PATH}/temporino"
URL_ARR=("https://github.com/Blackstareye/Random-Pokemon-Generator" "duh")
remove_submodules  ${URL_ARR[0]} $target