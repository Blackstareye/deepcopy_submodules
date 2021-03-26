#!/usr/bin/env bats
# those are functionality tests

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
    INI_TEST_FOLDER="ini_files/normal"
    INI_TEST_FOLDER=$(realpath ${INI_TEST_FOLDER})
    TEST_RESULT_FILE=$(realpath "test_result.tst")
    load "/test_helper/bats-support/load"
    load "/test_helper/bats-asserts/load"
    load "test.conf"
    load "testhelper.sh"
    # change directoy to script directory 
    changeDir "${SCRIPT_PATH}"
    # load libs
    load "log.sh"
    load "ini_parser.sh"
    make_TMP_DIR ${TMP_PATH}
    make_TMP_DIR ${LOG_PATH}

    ERROR_L="${LOG_PATH:?}/error.log"
    INFO_L="${LOG_PATH:?}/info.log"
    init_log "$LOG_PATH"
    clear_logs
}

@test "test ini contains 2 duplicates" {
    # can be calculates
    declare -a test_segments
    declare -a print_from_ini
    my_test_file=$(realpath "${INI_TEST_FOLDER:?}"/test_2_dup.ini)

    # greps the valid segment of the test result
    util_grep_test_result_content "${TEST_RESULT_FILE}" "${my_test_file}" > tmp.file
    
    # creates the list for ini segment checking
    # grep the parts with the brackets | delete the brackets, keep the content | put everything in one line | delete the remaining whitespace
    output_testfile=$(grep -e '\[.*\]' tmp.file | sed 's/\[\(.*\)\]/\1/' | tr '\n' ' ' | sed 's/ $//')
    #echo "${output_testfile}"
    segment_from_parser=$(parse_ini "${my_test_file}")

    echo "${segment_from_parser[@]}"
    cat tmp.file
    # have: 1. param
    # want: 2. param
    assert_equal "${segment_from_parser[@]}" "${output_testfile[@]}"


    print_from_ini=$(print_ini_auto "${my_test_file}")
    assert_equal "${print_from_ini}" "$(cat tmp.file)"    
    #run echo "hello"
    #assert_equal "hellao" "$output"
    rm tmp.file
}

@test "test ini contains 3 duplicates" {
    # can be calculates
    declare -a test_segments
    declare -a print_from_ini
    my_test_file=$(realpath "${INI_TEST_FOLDER:?}"/test_3_dup.ini)

    # greps the valid segment of the test result
    util_grep_test_result_content "${TEST_RESULT_FILE}" "${my_test_file}" > tmp.file
    
    # creates the list for ini segment checking
    # grep the parts with the brackets | delete the brackets, keep the content | put everything in one line | delete the remaining whitespace
    output_testfile=$(grep -e '\[.*\]' tmp.file | sed 's/\[\(.*\)\]/\1/' | tr '\n' ' ' | sed 's/ $//')
    #echo "${output_testfile}"
    segment_from_parser=$(parse_ini "${my_test_file}")

    echo "${segment_from_parser[@]}"
    cat tmp.file
    # have: 1. param
    # want: 2. param
    assert_equal "${segment_from_parser[@]}" "${output_testfile[@]}"


    print_from_ini=$(print_ini_auto "${my_test_file}")
    assert_equal "${print_from_ini}" "$(cat tmp.file)"    
    #run echo "hello"
    #assert_equal "hellao" "$output"
    rm tmp.file
}


@test "test  more than one file given" {
    # can be calculates
    declare -a test_segments
    declare -a print_from_ini
    declare -a my_test_files
    my_test_files=($(realpath "${INI_TEST_FOLDER:?}"/test_3_dup.ini))
    my_test_files+=($(realpath "${INI_TEST_FOLDER:?}"/test_10_dup.ini))
    run parse_ini ${my_test_files[@]}
    [[ "$status" == 1 ]]
    assert_output
}
@test "test  no file given" {
        # can be calculates
    declare -a test_segments
    declare -a print_from_ini
    declare -a my_test_files
    run parse_ini ${my_test_files[@]}
    [[ "$status" == 1 ]]
    assert_output
    
}
@test "test  file does not exist" {
            # can be calculates
    declare -a test_segments
    declare -a print_from_ini
    declare -a my_test_files
    run parse_ini "shrubbiduwaka_not_existing_file.file"
    [[ "$status" == 1 ]]
    assert_output
}

function teardown() {
     clear_logs
     clean_up_ini
}
