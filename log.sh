#!/usr/bin/env bash
# simple logging unit


LOGGING_FILE=""
INFO_CHANNEL=""
init_log() {
    LOG_PATH="${1}"
    LOGGING_FILE="${LOG_PATH}/error.log"
    INFO_CHANNEL="${LOG_PATH}/info.log"
}

error () {
    echo "$(date +"%c")" ["${1}"]: "${2}" >> "${LOGGING_FILE}"
}

info () {
    echo "$(date +"%c")" ["${1}"]: "${2}" >> "${INFO_CHANNEL}"
}

console() {
    echo "Error occured - ${1:-()}. Please refer the logs for further information."
}

console_exit () {
    echo "Error occured - ${1:-()}. program will be exited. Please refer the logs for further information."
    exit 1
}

clear_logs() {
    echo  > "${LOGGING_FILE}"
    echo  > "${INFO_CHANNEL}"
}