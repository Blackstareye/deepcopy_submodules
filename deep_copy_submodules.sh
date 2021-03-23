# !/bin/bash
# this script will deep copy the modules of a given git repo

# true if a tmp folder should be created or if you want to do the operations IN the given (local) folder
CREATE_TMP_FOLDER="true"
TMP_PATH="/tmp/submodule_pull_tmp"

# NOTE: this will be needed if you debug with bashdb (vscode)
DEBUG="true"
CLEAR_LOGS="true"
SCRIPT_PATH="/mnt/p/Software_Projekte/Skripte/deepcopy-submodules/"

# TODO License: GPL v3,
# if it is a remote  repo (remote <path>) it will clone the repo first
# if it is local it doesnt need that step

# Stop even, if a command in a pipe fails.
set -e -o pipefail
# let cdw be the actual  directory
# FOR DEBUG
if [[ "$DEBUG" == "true" ]]; then
    cd ${SCRIPT_PATH}
else
    cd "${0%/*}"
fi

CWD_PATH="$(pwd)"
GIT_MODULE_FILE=".gitmodules"
GIT_REMOTE_NAME="new_remote"
GIT_REMOTE_BRANCH="master"

SOURCE_LOCAL_URL=""
TARGET_REMOTE_URL=""

BASE_PATH=""
ROOT_URL=""
IS_LOCAL=false
IS_REMOTE=false
URL_EXIST=false
IS_SSH=false


INDEX=0
declare -a IS_VALID_ARR
declare -a URL_ARR

# TODO sanity check, check if both sources are available, else quit
# TODO sanity check, check if path is available

# import functions
# logging

source "log.sh"
init_log ${CWD_PATH}
if [[ "${CLEAR_LOGS}" == "true" ]]; then
    clear_logs
    info "CLEARED LOGS" "Cleared the logs."
    clear
fi
info "INFO PWD:" "PWD is : ${CWD_PATH}"

# util: ini parser
source "ini_parser.sh"

# help text method
help () {
    echo "Usuage: [remote/local] [source url] [target url]."
    echo "Remote : can be http(s) or ssh (experimental)"
    echo "Local : valid path to git root folder"
    echo "source url : url related to the type (remote/local)"
    echo "target url : url of the target (https or ssh (exp.))"
    echo "additional info: url will be validated, http(s) will be tested with curl before doing the deep copy."
}



is_valid_path() {
    if [[ -d ${1} ]]; then
        echo "true"
    else
        echo "false"
        log "ERROR - path validation" "Path ${1} is not a valid path."
    fi
    
}

# TODO logging
checkhttp() {
    if curl --output /dev/null --silent --head --fail "$1"; then
        # echo "URL exists: $1"
        echo "true"
    else
        #echo "given URL does not exist"
        echo "false"
        log "ERROR - checkhttp" "URL ${1}  does not response. Can't perform deep copy."
    fi
}

checkurl() {
    local returnvalue
    
    case $1 in
        "http"|"https")
            returnvalue=$(checkhttp $2)
        ;;
        *)
            log "ERROR - checkurl" "unknown type: ${1}"
        ;;
    esac
    echo ${returnvalue}
}
# checkssh() {
#     if nc -w 5 -z "$1" 22 ; then
#         echo "Port 22 on $1 is open"
#         #return 0
#         echo "true"
#     fi
#     echo "false"
# }


get_type() {
    if [[ $1 =~ ^http:// ]]; then
        echo "http"
        elif [[ $1 =~ ^https:// ]]; then
        echo "https"
        
        #elif [[ "$1" =~ "^(\w+@)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:([0-9]{1,5}|\w+.\w*))?(\/.*)?$" ]]; then
    else
        result=$(echo ${1} | grep -Eo '^(\w+@)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:([0-9]{1,5}|\w+.\w*))?(\/.*)?$')
        if [[ -n ${result} ]]; then
            echo "ssh"
            
        fi
        #echo "nothing"
    fi
}

validate_param() {
    # is_local is_remote local_url
    
    #echo $@
    local is_remote=${2}
    local is_local=${1}
    local local_url=${3}
    
    local is_valid
    local url_type
    
    if [[ "${is_local}" == true ]]; then
        info "MODE  = LOCAL"
        is_valid=$(is_valid_path ${local_url})
        if [[ ${is_valid} == "true" ]]; then
            info "URL STATUS = VALID"
        else
            info "URL STATUS = NOT VALID"
        fi
        
        elif [[ "${is_remote}" == true ]]; then
        info "MODE  = REMOTE"
        url_type=$(get_type ${local_url})
        if [[ "${url_type}" == "ssh" ]]; then
            IS_SSH="true"
            is_valid="true"
        else
            is_valid=$(checkurl "${url_type}" "${local_url}")
        fi
        
        if [[ "$is_valid" == true ]]; then
            info "CONNECTION  = EXIST"
            
            
            if [[ "${IS_SSH}" == true ]]; then
                info "TYPE  = SSH"
            else
                info "TYPE  = WEB"
            fi
        else
            info "CONNECTION  = NOT EXIST"
            info "CONNECTION  = deep copy can't be executed."
        fi
    else
        info "MODE  = UNDEFINED"
    fi
    
    info "URL   = ${LOCAL_URL}"
    
    #return the plausi value
    echo ${is_valid}
    
    # if [[ -n $1 ]]; then
    #     echo "Last line of the file specified as non-opt/last argument"
    # fi
    
}


# PARAMS
## check arguments
plausi_check() {
    local returnvalue
    local key
    local is_local
    local is_remote
    local local_url
    
    
    if [[ $# -eq 1 ]]; then
        local_url=${1}
        returnvalue=$(validate_param "false" "true" ${local_url})
        echo ${returnvalue} ${local_url}
        return 0
    fi
    
    key="$1"
    case $key in
        local| -l)
            local_url="$2"
            is_local=true
            is_remote=false
            shift;
            shift;
        ;;
        remote|-r)
            local_url="$2"
            is_local=false
            is_remote=true
            shift;
            shift;
        ;;
        help | -?)
            help
            shift;
            shift;
        ;;
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
        ;;
    esac
    
    returnvalue=$(validate_param ${is_local} ${is_remote} ${local_url})
    echo ${returnvalue} ${local_url}
}

# edit the git modules with the new urls
# following this guide
# https://www.w3docs.com/snippets/git/how-to-remove-a-git-submodule.html
# TODO NOTE: TOBETESTED
remove_submodules() {
    local submodule=""
    
    # change to base git
    cd "${1}"

    local removepath="${1}/${submodule}"
    
    info "RM gitmodules" "Removing ${1}/${GIT_MODULE_FILE}"
    
    # remove .gitmodules
    rm "${1}/${GIT_MODULE_FILE}"
    
    
    # edit .config
    local gitconfig_file="${1}/.git/config"
    local git_module_folder="${1}/.git/modules/"
    info "SED editing git config" "Removing Submodule entries in ${gitconfig_file}"
    # which  ,+2d -> delete line + 2 following lines
    sed -i '/\[submodule .*\]/,+2d' ${gitconfig_file}
    # unstaging submodule cache
    for section in ${section_list[@]}; do
        info "GITMODULE REMOVING - SUBMODULE"  "[${section}]"
        submodule="${section}"
        
        # remove submodule folder
        removepath="${1}/${submodule}"
        info "GITMODULE REMOVING - SUBMODULE Remove"  "[${section}] Remove Submodule folder in ${removepath}"
        git rm -r --cached ${removepath}
        info "GITMODULE REMOVING - SUBMODULE Remove"  "[${section}] Remove Submodule Cache folder in ${git_module_folder}/${section}"
        rm -rf "${git_module_folder}/${section}"
        
        # commit changes
        info "GITMODULE REMOVING - Commit changes"  "[${section}] Commit Changes"
        git commit -m "Removed submodule ${section}"
        
        # remove submodule folder
        info "GITMODULE REMOVING - Remove submodule folder"  "[${section}] remove folder: ${removepath}"
        rm -rf  ${removepath}
    done
    info "GITMODULE REMOVING" "Done Removing (${section_list[@]})"
}

# NOTE AND TODO TO BE TESTED
add_submodules_new_remote() {
    
    local remote_url="${URL_ARR[1]}/${section}.git"
    for section in ${section_list[@]}; do
        info "PUBLISHING TO NEW REMOTE"  "SUBMODULE: [${section}] changing directory ${1}/${section}"
        cd "${1}/${section}"
        remote_url="${URL_ARR[1]}/${section}.git"
        info "PUBLISHING TO NEW REMOTE"  "SUBMODULE: [${section}] with url: ${remote_url}"
        git remote add ${GIT_REMOTE_NAME} ${remote_url}
        info "PWD LOCATION" "$(pwd)"
        git push ${GIT_REMOTE_NAME} ${GIT_REMOTE_BRANCH}
    done
}

# NOTE AND TODO TO BE TESTED
add_submodules_local() {
    cd "${1}"
    local remote_url="${URL_ARR[1]}/${section}.git"
    for section in ${section_list[@]}; do
        info "ADDING SUBMODULE LOCALLY"  "SUBMODULE: [${section}] with path: ${1}"
        remote_url="${URL_ARR[1]}/${section}.git"
        git submodule add ${remote_url}
        git commit -m "Added the submodule ${section} to the project."
    done
}

push_changes() {
    cd "${1}"
    local remote_url="${URL_ARR[1]}/${BASE_PATH}.git"
    info "PUSH Changes of parent git repo"  "pushing local ${1} to ${remote_url}"
    git remote add ${GIT_REMOTE_NAME} ${remote_url}
    git push ${GIT_REMOTE_NAME} ${GIT_REMOTE_BRANCH}
    info "PUSH Changes of parent git repo"  "Done pushing"
}

clean_up() {
    # clean up actions
    if [[ "${CREATE_TMP_FOLDER}" ]]; then
        info "CLEANUP" "Cleaning up: ${SOURCE_LOCAL_URL}"
        rm -rf ${SOURCE_LOCAL_URL}/
    fi
}

# TODO trap clean_up ERR
error_actions() {
    echo "an error occured. See log what happened."
    echo "cleaning up"
    clean_up 
    echo "done."
}

main() {
    
    #  CHECK FIRST PARAM (local|remote url)
    if [[ $# -ne 3 ]]; then
        log "ERROR - PARAM SIZE" "Param Size needs to be at least 3 (type, source, target)"
        exit 1
    fi
    
    # collect if local or remote
    if [[ $1 == "local" ]]; then
        IS_LOCAL="true"
    fi
    if [[ $1 == "remote" ]]; then
        IS_REMOTE="true"
    fi
    
    declare -a values_a=($(plausi_check $@))
    IS_VALID_ARR+=(${values_a[0]})
    URL_ARR+=(${values_a[1]})
    # NOTE shift is always local not global
    shift;
    shift;
    #  CHECK SECOND PARAM (remote)
    declare -a values_b=($(plausi_check $@))
    # NOTE += does work, index + 1 not.
    IS_VALID_ARR+=(${values_b[0]})
    URL_ARR+=(${values_b[1]})
    # IS_VALID_ARR[1]= ${values_b[0]}
    # URL_ARR[1]=${values_b[1]}
    
    set -- "${POSITIONAL[@]}" # restore positional parameters
    #  GET MODULES
    
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
        BASE_PATH="$(basename ${URL_ARR[0]})"
        declare -p SOURCE_LOCAL_URL
    else
        log "ERROR-FATAL NOT LOCAL, NOT REMOTE" "Fatal error, values of is_local (v: ${IS_LOCAL}) and is_remote (v: ${IS_REMOTE}) are both not true."
        console_exit "ERROR- FATAL NOT LOCAL, NOT REMOTE"
    fi
    #  IF LOCAL
    
    local git_module_path=${SOURCE_LOCAL_URL}/${GIT_MODULE_FILE}
    if [[ -f  ${git_module_path} ]]; then
        # call ini parser:
        parse_ini ${git_module_path}
        if [[ ${CREATE_TMP_FOLDER} == "true" ]]; then
            # space is important
            if ! mkdir -p "${TMP_PATH}" || ! cp -rf ${SOURCE_LOCAL_URL}/. ${TMP_PATH}/; then
                log "ERROR - CREATING TMP_FOLDER" "Can't create tmp folder ${TMP_PATH}"
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
        log "ERROR" "Git Submodule File does not exist on path ${git_module_path}."
        console_exit "Git Submodule File does not exist on path ${git_module_path}."
    fi
    
    # LAST
    
    
}

# TODO to be tested
#trap clean_up EXIT #SIGINT
#trap error_actions ERR

# start program
main $@