#!/usr/bin/env bash
# caller for ini parsing
source "config.conf"
if [[ "$DEBUG" == "true" ]]; then
    cd ${SCRIPT_PATH} || exit 1
else
    cd "${0%/*}" || exit 1
fi
CWD_PATH="$(pwd)"

source "log.sh"
source "ini_parser.sh"
source "tst/testhelper.sh"

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



#create_test_output
#a=$(realpath tst/test_result.tst)
#b=$(realpath "tst/ini_files/normal/test_10.ini")

#util_grep_test_result_content "$a" "$b" > derp.txt
#parse_ini "$1"
#print_ini >> test_result.tst

# declare -a test_segments
# declare -a print_from_ini
#mkdir -p $TMP_PATH
# INI_TEST_FOLDER="tst/ini_files/normal"
# INI_TEST_FOLDER=$(realpath ${INI_TEST_FOLDER})
# TEST_RESULT_FILE=$(realpath "tst/test_result.tst")
# my_test_file=$(realpath "${INI_TEST_FOLDER:?}"/test_2_dup.ini)
# create_test_output
# # greps the valid segment of the test result
# util_grep_test_result_content "${TEST_RESULT_FILE}" "${my_test_file}" > tmp.file

# # creates the list for ini segment checking
# # grep the parts with the brackets | delete the brackets, keep the content | put everything in one line | delete the remaining whitespace
# output_testfile=$(grep -e '\[.*\]' tmp.file | sed 's/\[\(.*\)\]/\1/' | tr '\n' ' ' | sed 's/ $//')
# #echo "${output_testfile}"
# segment_from_parser=$(parse_ini "${my_test_file}")

# echo "${segment_from_parser[@]}"
# cat tmp.file
# # have: 1. param
# # want: 2. param
# assert_equal "${segment_from_parser[@]}" "${output_testfile[@]}"


# print_from_ini=$(print_ini_auto "${my_test_file}")
# assert_equal "${print_from_ini}" "$(cat tmp.file)"
# rm -r $TMP_PATH