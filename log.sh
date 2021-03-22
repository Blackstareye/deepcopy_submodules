LOGGING_FILE="error.log"
INFO_CHANNEL="info.log"

log () {
    echo $(date +"%c") [${1}]: ${2} >> ${LOGGING_FILE}
}

info () {
    echo $(date +"%c") [${1}]: ${2} >> ${INFO_CHANNEL}
}