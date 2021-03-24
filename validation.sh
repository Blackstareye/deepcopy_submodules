# !/usr/bin/env bash
# Submodule of deep_copy_submodules
# functions for the plausi check of the given arguments


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