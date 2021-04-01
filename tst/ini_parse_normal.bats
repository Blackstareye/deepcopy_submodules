#!/usr/bin/env bats
# those are functionality tests

function setup() {
    INI_TEST_FOLDER="ini_files/normal"
    INI_TEST_FOLDER=$(realpath ${INI_TEST_FOLDER})
    TEST_RESULT_FILE=$(realpath "report/test_parse_ini_result.tst")
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




function teardown() {
     clear_logs
     clean_up_ini
}


@test "test ini contains 10 entries" {
    # can be calculates
    declare -a test_segments
    declare -a print_from_ini
    my_test_file=$(realpath "${INI_TEST_FOLDER:?}"/test_10.ini)

    # greps the valid segment of the test result
    util_grep_test_result_content "${TEST_RESULT_FILE}" "${my_test_file}" > tmp.file
    
    # creates the list for ini segment checking
    # grep the parts with the brackets | delete the brackets, keep the content | put everything in one line | delete the remaining whitespace
    output_testfile=$(grep -e '\[.*\]' tmp.file | sed 's/\[\(.*\)\]/\1/' | tr '\n' ' ' | sed 's/ $//')
    #echo "${output_testfile}"
    segment_from_parser=$(parse_ini "${my_test_file}")

    #echo "${segment_from_parser[@]}"
    # have: 1. param
    # want: 2. param
    assert_equal "${segment_from_parser[@]}" "${output_testfile[@]}"


    print_from_ini=$(print_ini_auto "${my_test_file}")
    assert_equal "${print_from_ini}" "$(cat tmp.file)"    
    # run echo "hello"
    # assert_equal "hellao" "$output"
    rm tmp.file
}
@test "test ini contains 0 entries" {
    # can be calculates
    declare -a test_segments
    declare -a print_from_ini
    my_test_file=$(realpath "${INI_TEST_FOLDER:?}"/test_0.ini)

    # greps the valid segment of the test result
    #util_grep_test_result_content "${TEST_RESULT_FILE}" "${my_test_file}" > tmp.file
    
    # creates the list for ini segment checking
    # grep the parts with the brackets | delete the brackets, keep the content | put everything in one line | delete the remaining whitespace
    #output_testfile=$(grep -e '\[.*\]' tmp.file | sed 's/\[\(.*\)\]/\1/' | tr '\n' ' ' | sed 's/ $//')
    #echo "${output_testfile}"
    segment_from_parser=$(parse_ini "${my_test_file}")

    #echo "${segment_from_parser[@]}"
    # have: 1. param
    # want: 2. param
    assert_equal "${segment_from_parser[@]}" ""


    print_from_ini=$(print_ini_auto "${my_test_file}")
    assert_equal "${print_from_ini}" ""    
    # run echo "hello"
    # assert_equal "hellao" "$output"
    #rm tmp.file
}
@test "test ini contains 3 entries" {
    # can be calculates
    declare -a test_segments
    declare -a print_from_ini
    my_test_file=$(realpath "${INI_TEST_FOLDER:?}"/test_3.ini)

    # greps the valid segment of the test result
    util_grep_test_result_content "${TEST_RESULT_FILE}" "${my_test_file}" > tmp.file
    
    # creates the list for ini segment checking
    # grep the parts with the brackets | delete the brackets, keep the content | put everything in one line | delete the remaining whitespace
    output_testfile=$(grep -e '\[.*\]' tmp.file | sed 's/\[\(.*\)\]/\1/' | tr '\n' ' ' | sed 's/ $//')
    #echo "${output_testfile}"
    segment_from_parser=$(parse_ini "${my_test_file}")

    #echo "${segment_from_parser[@]}"
    # have: 1. param
    # want: 2. param
    assert_equal "${segment_from_parser[@]}" "${output_testfile[@]}"


    print_from_ini=$(print_ini_auto "${my_test_file}")
    assert_equal "${print_from_ini}" "$(cat tmp.file)"    
    # run echo "hello"
    # assert_equal "hellao" "$output"
    rm tmp.file
}




@test "test ini contains 1 entries values" {
    test_file="${INI_TEST_FOLDER:?}/test_1.ini"
    segments=("tinysubproject")
    keys=("url" "path")
    value_s=("tinysubproject" "http://blacklinux/blackeye/tinysubproject") 
    index_a=0
    
    # use run only if you dont have any global variables!!!
    parse_ini "${test_file}"
    for section in ${section_list[@]}; do
    assert_equal "${segments[$index_a]}" "${section}"
    for key in $(eval echo $\{'!'configuration_${section}[@]\}); do
        
        # check key is empty
        [[ -n "${key}" ]]
        # check key has the right value
        [[ "${keys[@]}" =~ .*${key}.* ]]

        # check if value is right
        tmp=$(give_value ${section} $key)
        # check if empty
        [[ -n "${tmp}" ]]
        # check if it is within the value list
        [[ "${value_s[@]}" =~ .*"${tmp}".* ]]
    done
    ((index_a=$index_a+1))
    done
}
@test "test ini contains 3 entries values" {
    test_file="${INI_TEST_FOLDER:?}/test_3.ini"
    segments=("tinysubproject" "tinysubprojecta" "tinysubprojectb")
    keys=("url" "path")
    value_s=("tinysubproject" "http://blacklinux/blackeye/tinysubproject" "tinysubprojectA" "http://blacklinux/blackeye/tinysubprojectA" "tinysubprojectB" "http://blacklinux/blackeye/tinysubprojectB") 
    index_a=0
    
    # use run only if you dont have any global variables!!!
    parse_ini "${test_file}"
    for section in ${section_list[@]}; do
    assert_equal "${segments[$index_a]}" "${section}"
    for key in $(eval echo $\{'!'configuration_${section}[@]\}); do
        
        # check key is empty
        [[ -n "${key}" ]]
        # check key has the right value
        [[ "${keys[@]}" =~ .*${key}.* ]]

        # check if value is right
        tmp=$(give_value ${section} $key)
        # check if empty
        [[ -n "${tmp}" ]]
        # check if it is within the value list
        [[ "${value_s[@]}" =~ .*"${tmp}".* ]]
    done
    ((index_a=$index_a+1))
    done
}



# @test "test ini contains 0 entries" {
#     local test_file="${INI_TEST_FOLDER:?}/test_0.ini"   
#     run 
# }


