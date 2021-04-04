#!/usr/bin/env bash
# Author: Blackeye
# TODO License: GPL v3,
# this script will deep copy the modules of a given git repo
# if it is a remote  repo (remote <path>) it will clone the repo first
# if it is local it doesnt need that step
CONFIG_FILE="$HOME/.conf/submodule_deepcopy/config.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: No config found."
    echo "Please run the script install.sh before using this program."
    exit 1
fi

SOURCE_LOCAL_URL=""
BASE_PATH=""
IS_LOCAL=false
IS_REMOTE=false
# url validation array (true: valid url)
declare -a IS_VALID_ARR
# contains the 2 urls
declare -a URL_ARR

# Stop even, if a command in a pipe fails.
set -e -o pipefail


# let cdw be the actual  directory
source "$CONFIG_FILE"

# change directory to script directory
cd "${SCRIPT_PATH}" || { echo "can't change directory to script path: ${SCRIPT_PATH}."; echo "Please ensure that SCRIPT_PATH in $CONFIG_FILE is the path to deep_copy_submodules."; echo "Otherwise use install.sh within the deep_copy_submodules folder and run this script again."; exit 1; }
CWD_PATH=$(pwd)

# import functions
# ui settings and lines
source "ui_lines.sh"
# logging
source "log.sh"
# ini parser
source "ini_parser.sh"
# validation of arguments
source "validation.sh"
# git operations
source "git_operations.sh"



clean_up() {
    # clean up actions
    if [[ "${CREATE_TMP_FOLDER}" ]]; then
        info "CLEANUP" "Cleaning up: ${SOURCE_LOCAL_URL}"
        # Using :? will cause the command to fail if the variable is null or unset. Similarly, you can use :- to set a default value if applicable.
        rm -rf "${SOURCE_LOCAL_URL:?}"/
    fi
    [[ -f "tmp.file" ]] && rm "tmp.file"
    
}

# TODO trap clean_up ERR
error_actions() {
    echo "an error occured. See log what happened."
    echo "cleaning up"
    clean_up
    echo "done."
}

get_params() {
    #  CHECK FIRST PARAM (local|remote url)
    key="$1"
    case $key in
        --help | -h | -"?")
            help
            shift;
            shift;
            exit 0
        ;;
        --usuage | -u)
            usuage
            exit 0
    esac
    
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
    if [[ $1 == "ssh" ]]; then
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
    
    set -- "${POSITIONAL[@]}" # restore positional parameters
}

clone_repo_from_remote() {
    local basename_repo=$(basename "${URL_ARR[0]}")
    local target="${TMP_PATH}/${basename_repo}"
    mkdir -p "$target"
    # git remote
    # go into the the directory
    clone_remote "${URL_ARR[0]}" ${target}
    SOURCE_LOCAL_URL=$(realpath ${target})
    BASE_PATH="$(basename "${target}")"
    # tmp folder is already created
    CREATE_TMP_FOLDER="false"
}


main() {
    
    echo "Getting Params and validating them if necessary..."
    get_params "$@"
    
    print_status "${URL_ARR[@]}"
    if [[ "${VALIDATION}" == "true" && "${IS_VALID_ARR[0]}" != "true" || "${IS_VALID_ARR[1]}" != "true" ]]; then
        error "URLS not valid" "There are urls that are not valid: ${IS_VALID_ARR[0]}:${URL_ARR[0]} ; ${IS_VALID_ARR[1]}:${URL_ARR[1]} ; VALIDATION_FLAG=${VALIDATION}"
        console_exit "URLS not valid"
    fi
    if [[ ${IS_REMOTE} == "true" ]]; then
        
        echo "Extra Task: Cloning repo now...."
        clone_repo_from_remote
        echo "Extra Task: Cloning repo done."
        
        elif [[ ${IS_LOCAL} == "true" ]]; then
        SOURCE_LOCAL_URL=${URL_ARR[0]}
        BASE_PATH="$(basename "${URL_ARR[0]}")"
    else
        error "ERROR-FATAL NOT LOCAL, NOT REMOTE" "Fatal error, values of is_local (v: ${IS_LOCAL}) and is_remote (v: ${IS_REMOTE}) are both not true."
        console_exit "ERROR- FATAL NOT LOCAL, NOT REMOTE"
    fi
    #  IF LOCAL
    
    local git_module_path=${SOURCE_LOCAL_URL}/${GIT_MODULE_FILE}
    if [[ -f  ${git_module_path} ]]; then
        # call ini parser:
        
        if [[ ${CREATE_TMP_FOLDER} == "true" ]]; then
            # space is important
            rm -rf "${TMP_PATH:?}"
            if ! mkdir -p "${TMP_PATH}" || ! cp -rf "${SOURCE_LOCAL_URL:?}"/. ${TMP_PATH}/; then
                error "ERROR - CREATING TMP_FOLDER" "Can't create tmp folder ${TMP_PATH}"
                console_exit "ERROR - CREATING TMP_FOLDER" "true"
            fi
            SOURCE_LOCAL_URL=${TMP_PATH}
        fi
        [[ $DEBUG ]] && echo "DEBUG: Parsing Ini now..."
        parse_ini "${git_module_path}" > /dev/null
        [[ $DEBUG ]] && echo "DEBUG: Parsing Ini done"
        [[ $DEBUG ]] && echo "DEBUG: Using folder $COLOR_YELLOW $SOURCE_LOCAL_URL $COLOR_RESET for uploading now."
        # prepare .gitmodules
        # change all url with new domain url
        # First push submodules
        # then delete and change root git
        [[ $DEBUG ]] && show_info "$SOURCE_LOCAL_URL" "$git_module_path" "${URL_ARR[1]}"
        echo "=======Main Tasks======="
        echo "(1/5): Uploading submodules to $COLOR_YELLOW ${URL_ARR[1]} $COLOR_RESET"
        add_submodules_new_remote ${SOURCE_LOCAL_URL}
        echo "(2/5): Removing now local submodules ... "
        remove_submodules ${SOURCE_LOCAL_URL}
        
        
        echo "(3/5): Adding submodules locally with new remote..."
        add_submodules_local ${SOURCE_LOCAL_URL}
        
        echo "(4/5): Pushing repo with new remote urls to $COLOR_YELLOW ${URL_ARR[1]} $COLOR_RESET..."
        push_changes ${SOURCE_LOCAL_URL}
        
        echo "(5/5): Cleaning up..."
        clean_up
        echo "Program finished. Git repo migration sucessfull. You can now visit your repo at $COLOR_YELLOW ${URL_ARR[1]} $COLOR_RESET"
    else
        error "ERROR" "Git Submodule File does not exist on path ${git_module_path}."
        console_exit "Git Submodule File does not exist on path ${git_module_path}."
    fi
    
}
# IMPROVE enable traps?
#trap clean_up EXIT #SIGINT
#trap error_actions ERR

# start program
init_deepcopy() {
    init_log "${LOG_PATH:-${CWD_PATH}}"
    if [[ "${CLEAR_LOGS}" == "true" ]]; then
        clear_logs
        info "CLEARED LOGS" "Cleared the logs."
        #clear
    fi
    info "INFO PWD:" "PWD is : ${LOG_PATH:-${CWD_PATH}}"
}

init_deepcopy
main "$@"
exit 0