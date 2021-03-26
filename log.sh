#!/usr/bin/env bash
# simple logging unit

LOGGING_FILE=""
INFO_CHANNEL=""
IS_INIT="false"
init_log() {
    if [[ -d "${1}" ]]; then
        LOG_PATH="${1}"
        LOGGING_FILE="${LOG_PATH}/error.log"
        INFO_CHANNEL="${LOG_PATH}/info.log"
        IS_INIT="true"
    else
        echo "no logging possible, given path is not a valid path: ${1}"
        IS_INIT="false"
        return 1
    fi
}

error () {
    if [[ "${IS_INIT}" == "true" ]]; then
        echo "$(date +"%c")" ["${1}"]: "${2}" >> "${LOGGING_FILE}"
    else
        echo "warning: logger not initialized. No logging possible."
        return 1
    fi
}

info () {
    if [[ "${IS_INIT}" == "true" ]]; then
        echo "$(date +"%c")" ["${1}"]: "${2}" >> "${INFO_CHANNEL}"
    else
        echo "warning: logger not initialized. No logging possible."
        return 1
    fi
}

console() {
    echo "Error occured - ${1:-()}. Please refer the logs for further information."
}

console_exit () {
    echo "Error occured - ${1:-()}. program will be exited. Please refer the logs for further information."
    exit 1
}

clear_logs() {
        if [[ "${IS_INIT}" == "true" ]]; then
            echo  > "${LOGGING_FILE:-/dev/null}"
            echo  > "${INFO_CHANNEL:-/dev/null}"
            return 0
        else
            return 1
        fi
}