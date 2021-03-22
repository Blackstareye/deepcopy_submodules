LOGGING_FILE="error.log"
INFO_CHANNEL="info.log"

log () {
    echo $(date +"%c") [${1}]: ${2} >> ${LOGGING_FILE}
}

info () {
    echo $(date +"%c") [${1}]: ${2} >> ${INFO_CHANNEL}
}

console() {
    echo "Error occured - ${1}. Please refer the logs for further information."
}

console_exit () {
    echo "Error occured - ${1}. program will be exited. Please refer the logs for further information."
    exit 1
}