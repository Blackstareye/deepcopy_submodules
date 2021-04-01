#!/usr/bin/env bash
# this is the integration test of the project
# this is the integration test ini - tst/integration_test/integration_test.ini
# shellcheck disable=SC2088
INTEGRATION_TEST_CONF="~/integration_test.conf"
REPORT_FILE=$(realpath "tst/report/integration_test.params")
VISIBLE_PASSWORD="false"
#cd "${0%/*}" || exit 1

get_file_content() {
    # shellcheck source=/dev/null
    source "${INTEGRATION_TEST_CONF//\~/$HOME}"
}

give_values() {
    local topic="$1"
    local tmp
    local expression
    
    declare -a response
    expression="${topic}_url1"
    tmp="${!expression}"
    response+=("${tmp:-"_"}")
    expression="${topic}_url2"
    tmp="${!expression}"
    response+=("${tmp:-"_"}")
    expression="${topic}_user1"
    tmp="${!expression}"
    response+=("${tmp:-"_"}")
    expression="${topic}_pw1"
    tmp="${!expression}"
    response+=("${tmp:-"_"}")
    expression="${topic}_user2"
    tmp="${!expression}"
    response+=("${tmp:-"_"}")
    expression="${topic}_pw2"
    tmp="${!expression}"
    response+=("${tmp:-"_"}")
    echo "${response[*]}"
}

get_ssh() {
    argument="sshtest"
    #give_values
    # shellcheck disable=2207
    values=($(give_values ${argument}))
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
    argument="localhttpstest"
    #give_values
    # shellcheck disable=2207
    values=($(give_values ${argument}))
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
    argument="localsshtest"
    #give_values
    # shellcheck disable=2207
    values=($(give_values ${argument}))
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
    argument="remotehttpstest"
    #give_values
    # shellcheck disable=2207
    values=($(give_values ${argument}))
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
    # shellcheck disable=1091
    source "log.sh"
    # shellcheck disable=1091
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

setup
if [[ "$1" == "-s" ]]; then
    
    echo "" > "$REPORT_FILE"
    # shellcheck disable=SC2129
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



