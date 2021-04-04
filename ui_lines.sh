#!/usr/bin/env bash
# this file does contain all necessary ui settings
# Set Colors
if [[ -z "$TURN_COLOR_OFF" || "$TURN_COLOR_OFF" == "false" ]]; then
    COLOR_RED=$'\e[31m'
    COLOR_CYAN=$'\e[36m'
    COLOR_YELLOW=$'\e[93m'
    COLOR_GREEN=$'\e[32m'
    COLOR_RESET=$'\e[0m'
fi

# help text method
help () {
    usuage
    #echo "Usuage: [remote/local/ssh] [-] [source url] [target url]."
    echo "$COLOR_CYAN type_for_first_url $COLOR_RESET:"
    echo "      $COLOR_CYAN-remote:$COLOR_RESET can be http(s) "
    echo "      $COLOR_CYAN-ssh:$COLOR_RESET valid ssh url (experimental)"
    echo "      $COLOR_CYAN-local:$COLOR_RESET valid path to git root folder"
    echo " options:"
    echo "      --validate | --check | -v | -c: validate url syntax before use. if -t is enabled, it will also check if the url connection can be established."
    echo "      --test-connections | -t: check if the url connection can be established using curl. Works not for ssh so far."
    echo "$COLOR_YELLOW source url:$COLOR_RESET url related to the $COLOR_CYAN url type (remote/local/ssh) $COLOR_RESET"
    echo "$COLOR_YELLOW target url:$COLOR_RESET url of the target. must be $COLOR_CYAN remote $COLOR_RESET"
    echo "additional info: url will be validated, http(s) will be tested with curl before doing the deep copy if the flags (or set in the config)."
}
# help text method
usuage () {
    echo "$0: [-v|--validate|-c|--check] [-t|--test-connections] [--usage] [-h|--help] $COLOR_CYAN type_for_fist_url $COLOR_RESET $COLOR_YELLOW source_url target_url $COLOR_RESET"
}

print_status() {
    local url1="$1"
    local url2="$2"
    
    local url1_val
    local url2_val
    local green_true="${COLOR_GREEN}true$COLOR_RESET"
    local red_false="${COLOR_RED}false$COLOR_RESET"
    if [[ "${IS_VALID_ARR[0]}" == "true" ]]; then
        url1_val="$green_true"
    else
        url1_val="$red_false"
    fi
    if [[ "${IS_VALID_ARR[1]}" == "true" ]]; then
        url2_val="$green_true"
    else
        url2_val="$red_false"
    fi
    # first :
    echo "============URLs=================="
    echo "repo that will be copied: $COLOR_YELLOW${url1}$COLOR_RESET(valid:$url1_val)"
    echo "to: $COLOR_YELLOW ${url2}$COLOR_RESET(valid:$url2_val)"
    echo "=============================="
    if [[ "$DEBUG" == "true" ]]; then
        printf "VALIDATION=$COLOR_YELLOW%s$COLOR_RESET, TEST_CONNECTIONS=$COLOR_YELLOW%s$COLOR_RESET \n" "$VALIDATION" "$TEST_CONNECTIONS"
        printf "log_path=$COLOR_YELLOW%s$COLOR_RESET \n"  "$LOG_PATH "
        printf "config=$COLOR_YELLOW%s$COLOR_RESET \n"  "$CONFIG_FILE"
        echo "=============================="
    fi
    read -rp "is that corect? [Y/n]" -n 1 answer
    if [[ "$answer" == "n" ]]; then
        echo "Deep Copy Aborted. Please fix your params." && exit 1
    fi
}

show_info() {
    echo "DEBUG CHECK:"
    echo "Before continuing to the main task, please verify the parameters:"
    echo "=============================="
    printf "Temp Repo Path: $COLOR_YELLOW%s$COLOR_RESET \n" "$1"
    printf "Git Module File: $COLOR_YELLOW%s$COLOR_RESET \n" "$2"
    printf "Remote Adress: $COLOR_YELLOW%s$COLOR_RESET \n" "$3"
    echo "=============================="
    read -rp "all corect? [Y/n]" -n 1 answer
    if [[ "$answer" == "n" ]]; then
        echo "Deep Copy Aborted. Please fix your params." && exit 1
    fi
}