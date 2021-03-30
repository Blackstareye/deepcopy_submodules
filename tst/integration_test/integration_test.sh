#!/usr/bin/env bash
# this is the integration test of the project
# this is the integration test ini - tst/integration_test/integration_test.ini
INTEGRATION_TEST_INI="~/integration_test.ini"
REPORT_FILE=$(realpath "tst/report/integration_test.params")
VISIBLE_PASSWORD="false"
#cd "${0%/*}" || exit 1

give_values() {
    local topic="$1"
    local tmp=""
    shift
    arg=("${@}")
    declare -a response
    for request in "${arg[@]}"; do
        tmp="$(give_value "$topic" "$request")"
        response+=("${tmp:-"_"}")
    done
    echo "${response[*]}"
}

get_ssh() {
    setup
    arguments=("sshtest" "url1" "url2" "user1" "pw1" "user2" "pw2")
    #give_values
    values=($(give_values ${arguments[*]}))
    if [[ "${VISIBLE_PASSWORD}" == "false" ]]; then
        # obfuscate passwords
        values[3]="*********"
        values[5]="*********"
    fi
    echo "command: deep_copy_submodules.sh \"ssh\" \"${values[0]}\" \"${values[1]}\""
    echo "for url1 - user/password: ${values[2]:-"-"}/${values[3]:-"-"}"
    echo "for url2 - user/password: ${values[4]:-"-"}/${values[5]:-"-"}"
}

get_local_https() {
    setup
    arguments=("localhttpstest" "url1" "url2" "user1" "pw1" "user2" "pw2")
    #give_values
    values=($(give_values ${arguments[*]}))
    if [[ "${VISIBLE_PASSWORD}" == "false" ]]; then
        # obfuscate passwords
        values[3]="*********"
        values[5]="*********"
    fi
    echo "command: deep_copy_submodules.sh \"local\" \"${values[0]}\" \"${values[1]}\""
    echo "for url1 - user/password: ${values[2]:-"-"}/${values[3]:-"-"}"
    echo "for url2 - user/password: ${values[4]:-"-"}/${values[5]:-"-"}"
}
get_local_ssh() {
    setup
    arguments=("localsshtest" "url1" "url2" "user1" "pw1" "user2" "pw2")
    #give_values
    values=($(give_values ${arguments[*]}))
    if [[ "${VISIBLE_PASSWORD}" == "false" ]]; then
        # obfuscate passwords
        values[3]="*********"
        values[5]="*********"
    fi
    echo "command: deep_copy_submodules.sh \"ssh\" \"${values[0]}\" \"${values[1]}\""
    echo "for url1 - user/password: ${values[2]:-"-"}/${values[3]:-"-"}"
    echo "for url2 - user/password: ${values[4]:-"-"}/${values[5]:-"-"}"
}
get_remote_https_test() {
    setup
    arguments=("remotehttpstest" "url1" "url2" "user1" "pw1" "user2" "pw2")
    #give_values
    values=($(give_values ${arguments[*]}))
    if [[ "${VISIBLE_PASSWORD}" == "false" ]]; then
        # obfuscate passwords
        values[3]="*********"
        values[5]="*********"
    fi
    echo "command: deep_copy_submodules.sh \"remote\" \"${values[0]}\" \"${values[1]}\""
    echo "for url1 - user/password: ${values[2]:-"-"}/${values[3]:-"-"}"
    echo "for url2 - user/password: ${values[4]:-"-"}/${values[5]:-"-"}"
}

load_lib() {
    source "log.sh"
    source "ini_parser.sh"
}

get_log() {
    LOG_PATH="/tmp/log_caller_tmp"
    mkdir -p ${LOG_PATH}
    init_log $LOG_PATH
    clear_logs
}
teardown() {
    rm "$TMP_PATH/tmp.ini"
}

setup () {
    #if [[ -f ]]
    load_lib
    get_log
    get_file_content
}
get_file_content() {
    TMP_PATH="/tmp"
    x="${INTEGRATION_TEST_INI//\~/$HOME}"
    parse_ini_without_preparsing $x > /dev/null
}

interrogate() {
    echo "Welcome to the integration testing - Please select the way you want to test:"
    # echo "1) ssh-test"
    # echo "2) local to https"
    # echo "3) local to ssh"
    # echo "4) remote both https"
    select choice in "ssh-test" "local to https" "local to ssh" "remote both https"
    do
        
        case $choice in
            # Two case values are declared here for matching
            "ssh-test")
                get_ssh
                exit 0
            ;;
            # Three case values are declared here for matching
            "local to https")
                get_local_https
                exit 0
            ;;
            "local to ssh")
                get_local_ssh
                exit 0
            ;;
            "remote both https")
                get_remote_https_test
                exit 0
            ;;
            # Matching with invalid data
            *)
                echo "Invalid entry."
                exit 1
                break
            ;;
        esac
    done
}

if [[ "$1" == "-s" ]]; then
    echo "" > "$REPORT_FILE"
    
    echo "SSH Test 1:" >> "$REPORT_FILE"
    echo "============" >> "$REPORT_FILE"
    get_ssh >> "$REPORT_FILE"
    echo "============" >> "$REPORT_FILE"
    echo "Local to ssh Test 2:" >> "$REPORT_FILE"
    echo "============" >> "$REPORT_FILE"
    get_local_ssh >> "$REPORT_FILE"
    echo "============" >> "$REPORT_FILE"
    echo "Local to https Test 3:" >> "$REPORT_FILE"
    get_local_https >> "$REPORT_FILE"
    echo "============" >> "$REPORT_FILE"
    echo "https to https Test 4:" >> "$REPORT_FILE"
    get_remote_https_test >> "$REPORT_FILE"
    echo "============" >> "$REPORT_FILE"
else
    interrogate
fi



