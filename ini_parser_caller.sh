#!/usr/bin/env bash

source "config.conf"
if [[ "$DEBUG" == "true" ]]; then
    cd ${SCRIPT_PATH}
else
    cd "${0%/*}"
fi
CWD_PATH="$(pwd)"

source "log.sh"
source "ini_parser.sh"

if [[ "$DEBUG" == "true" ]]; then
    cd ${SCRIPT_PATH}
else
    cd "${0%/*}"
fi
CWD_PATH="$(pwd)"

init_log "${LOG_PATH:-${CWD_PATH}}"
if [[ "${CLEAR_LOGS}" == "true" ]]; then
    clear_logs
    info "CLEARED LOGS" "Cleared the logs."
    echo "" > tst/test_result.tst
    clear
fi

#parse_ini ${1}

#give_value "tinysubproject" "url"


#print
create_test_output() {
    files="tst/ini_files/normal/*"
    for file in $files; do
        file_real=$(realpath "${file}")
        parse_ini "$file_real"
        echo "=============================$file_real===================================================================================================="
        echo "=============================$file_real====================================================================================================" >> tst/test_result.tst
        print_ini >> tst/test_result.tst
    done
    clear_logs
}



create_test_output
a=$(realpath tst/test_result.tst)
b=$(realpath "tst/ini_files/normal/test_10.ini")
source "tst/testhelper.sh"
util_grep_test_result_content "$a" "$b" > derp.txt
#parse_ini "$1"
#print_ini >> test_result.tst

