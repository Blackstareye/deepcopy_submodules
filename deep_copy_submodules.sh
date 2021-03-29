#!/usr/bin/env bash
# this script will deep copy the modules of a given git repo

# TODO License: GPL v3,
# if it is a remote  repo (remote <path>) it will clone the repo first
# if it is local it doesnt need that step

# Stop even, if a command in a pipe fails.
set -e -o pipefail

# Configuration load
source "config.conf"

# import functions
# logging
source "log.sh"
# ini parser
source "ini_parser.sh"
# validation of arguments
source "validation.sh"
# git operations
source "git_operations.sh"


# let cdw be the actual  directory
# FOR DEBUG
if [[ "$DEBUG" == "true" ]]; then
    cd ${SCRIPT_PATH}
else
    cd "${0%/*}"
fi
CWD_PATH="$(pwd)"


SOURCE_LOCAL_URL=""

BASE_PATH=""
IS_LOCAL=false
IS_REMOTE=false
#IS_SSH=false



# TODO sanity check, check if both sources are available, else quit
# TODO sanity check, check if path is available


init_log "${LOG_PATH:-${CWD_PATH}}"
if [[ "${CLEAR_LOGS}" == "true" ]]; then
    clear_logs
    info "CLEARED LOGS" "Cleared the logs."
    clear
fi
info "INFO PWD:" "PWD is : ${LOG_PATH:-${CWD_PATH}}"


# help text method
help () {
    echo "Usuage: [remote/local] [source url] [target url]."
    echo "Remote : can be http(s) or ssh (experimental)"
    echo "Local : valid path to git root folder"
    echo "source url : url related to the type (remote/local)"
    echo "target url : url of the target (https or ssh (exp.))"
    echo "additional info: url will be validated, http(s) will be tested with curl before doing the deep copy."
}

clean_up() {
    # clean up actions
    if [[ "${CREATE_TMP_FOLDER}" ]]; then
        info "CLEANUP" "Cleaning up: ${SOURCE_LOCAL_URL}"
        # Using :? will cause the command to fail if the variable is null or unset. Similarly, you can use :- to set a default value if applicable.
        rm -rf "${SOURCE_LOCAL_URL:?}"/
    fi
    #TODO enable clean_up_ini
}

# TODO trap clean_up ERR
error_actions() {
    echo "an error occured. See log what happened."
    echo "cleaning up"
    clean_up 
    echo "done."
}


GIT_MODULE_FILE=".gitmodules"
# url validation array (true: valid url)
declare -a IS_VALID_ARR
# contains the 2 urls
declare -a URL_ARR
main() {
    
    #  CHECK FIRST PARAM (local|remote url)
    if [[ $# -ne 3 ]]; then
        error "ERROR - PARAM SIZE" "Param Size needs to be at least 3 (type, source, target)"
        exit 1
    fi
    
    # collect if local or remote
    if [[ $1 == "local" ]]; then
        IS_LOCAL="true"
    fi
    if [[ $1 == "remote" ]]; then
        IS_REMOTE="true"
    fi
    # shellcheck disable=SC2207
    declare -a values_a=($(plausi_check "$@"))
    IS_VALID_ARR+=("${values_a[0]}")
    URL_ARR+=("${values_a[1]}")
    # NOTE shift is always local not global
    shift;
    shift;
    #  CHECK SECOND PARAM (remote)
    # shellcheck disable=SC2207
    declare -a values_b=($(plausi_check "$@"))
    # NOTE += does work, index + 1 not.
    IS_VALID_ARR+=("${values_b[0]}")
    URL_ARR+=("${values_b[1]}")
    # IS_VALID_ARR[1]= ${values_b[0]}
    # URL_ARR[1]=${values_b[1]}
    
    set -- "${POSITIONAL[@]}" # restore positional parameters
    #  GET MODULES
    # TOBE TESTED
    if [[ "${VALIDATION}" == "true" && "${IS_VALID_ARR[0]}" != "true" || "${IS_VALID_ARR[1]}" != "true" ]]; then
        error "URLS not valid" "There are urls that are not valid: ${IS_VALID_ARR[0]}:${URL_ARR[0]} ; ${IS_VALID_ARR[1]}:${URL_ARR[1]} ; VALIDATION_FLAG=${VALIDATION}"
        console_exit "URLS not valid"
    fi
    if [[ ${IS_REMOTE} == "true" ]]; then
        
        #  IF REMOTE
        #  check out  , perform, delete
        #  ask where to put the folder
        #  ENTER=local folder
        # TODO
        # SOURCE_LOCAL fill then path
        echo remote
        # BASE_PATH="$(basename ${URL_ARR[0]})"
    elif [[ ${IS_LOCAL} == "true" ]]; then
        SOURCE_LOCAL_URL=${URL_ARR[0]}
        BASE_PATH="$(basename "${URL_ARR[0]}")"
        declare -p SOURCE_LOCAL_URL
    else
        error "ERROR-FATAL NOT LOCAL, NOT REMOTE" "Fatal error, values of is_local (v: ${IS_LOCAL}) and is_remote (v: ${IS_REMOTE}) are both not true."
        console_exit "ERROR- FATAL NOT LOCAL, NOT REMOTE"
    fi
    #  IF LOCAL
    
    local git_module_path=${SOURCE_LOCAL_URL}/${GIT_MODULE_FILE}
    if [[ -f  ${git_module_path} ]]; then
        # call ini parser:
        parse_ini "${git_module_path}"
        if [[ ${CREATE_TMP_FOLDER} == "true" ]]; then
            # space is important
            if ! mkdir -p "${TMP_PATH}" || ! cp -rf "${SOURCE_LOCAL_URL:?}"/. ${TMP_PATH}/; then
                error "ERROR - CREATING TMP_FOLDER" "Can't create tmp folder ${TMP_PATH}"
                console_exit "ERROR - CREATING TMP_FOLDER" "true"
            fi
            SOURCE_LOCAL_URL=${TMP_PATH}
        fi
        
        # prepare .gitmodules
        # change all url with new domain url
        # First push submodules
        # then delete and change root git
        add_submodules_new_remote ${SOURCE_LOCAL_URL}
        
        remove_submodules ${SOURCE_LOCAL_URL}
        
        
        #TODO add_submodules_local
        add_submodules_local ${SOURCE_LOCAL_URL}
        
        push_changes ${SOURCE_LOCAL_URL}

        echo "Program finished. Git repo migration sucessfull."
        
        clean_up
    else
        error "ERROR" "Git Submodule File does not exist on path ${git_module_path}."
        console_exit "Git Submodule File does not exist on path ${git_module_path}."
    fi
    
    # LAST
    
    
}

# TODO to be tested
#trap clean_up EXIT #SIGINT
#trap error_actions ERR

# start program
main "$@"