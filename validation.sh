#!/usr/bin/env bash
# Submodule of deep_copy_submodules
# functions for the plausi check of the given arguments


is_valid_path() {
    if [[ -d ${1} ]]; then
        echo "true"
    else
        echo "false"
        error "ERROR - path validation" "Path ${1} is not a valid path."
    fi
    
}

# TODO logging
checkhttp() {
    if curl --output /dev/null --silent --head --fail "$1"; then
        # echo "URL exists: $1"
        echo "true"
    else
        # try without head
        if curl --output /dev/null --silent --fail "$1"; then
            echo "true"
        else
            #given URL does not exist
            echo "false"
            error "ERROR - checkhttp" "URL ${1}  does not response. Can't perform deep copy."
        fi
    fi
}

checkssh() {
    # local server="$1"      # server IP
    # local port=22                 # port
    # local connect_timeout=5       # Connection timeout
    # local command_output
    
    # command_output=$(ssh -q -o BatchMode=yes  -o StrictHostKeyChecking=no -o ConnectTimeout=$connect_timeout "$server" 'exit 0')
    # if [[ -n $command_output ]]; then
    #     info "SSH Connection to $server is possible"
    #     echo "true"
    # else
    #     error "SSH CONNECTION FAULT" "SSH connection to $server over port $port is not possible"
    #     echo "false"
    # fi
    info "WARNING EXPERIMANTEL FEATURE USE SSH" "WARNING SSH Can't be validated right now if connection is alive or not." 
    echo "unknown"
}

checkurl() {
    local returnvalue
    local is_ssh="$3"
    case $1 in
        "http"|"https")
            returnvalue=$(checkhttp "$2")
        ;;
        "ssh")
            returnvalue=$(checkssh "$2")
        ;;
        *)

                error "ERROR - checkurl" "unknown type: ${1}."
                #console "Please specify the protocoll (http, https) or use 'shell' instead of remote for 'ssh' connections"
                returnvalue="false"

        ;;
    esac
    echo "${returnvalue}"
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
    else
        echo "other"
    fi
}

validate_param() {
    # is_local is_remote local_url
    
    #echo $@
    local is_remote=${2}
    local is_local=${1}
    local is_ssh=${3}
    local local_url=${4}
    
    local is_valid
    local url_type
    
    if [[ "${is_local}" == true ]]; then
        info "MODE  = LOCAL"
        is_valid=$(is_valid_path "${local_url}")
        if [[ ${is_valid} == "true" ]]; then
            info "URL STATUS = VALID"
        else
            info "URL STATUS = NOT VALID"
        fi
    elif [[ "${is_remote}" == true ]]; then
        info "INFO_ MODE REMOTE" "MODE  = REMOTE"
        if [[ "${is_ssh}" == true ]]; then
            url_type="ssh"
        else
            url_type=$(get_type "${local_url}")
        fi
        is_valid=$(checkurl "${url_type}" "${local_url}" "${is_ssh}")
    
        
        if [[ "$is_valid" == true ]]; then
            info "CONNECTION  = EXIST"
        
        elif [[ "${is_valid}" == "unknown" ]]; then
            if [[ "${is_ssh}" == true ]]; then
                info "TYPE  = SSH"
            fi
        else
            info "CONNECTION  = NOT VALID"
            info "CONNECTION  = deep copy can't be executed."
        fi
    else
        info "MODE  = UNDEFINED"
    fi
    
    info "URL   = ${local_url}"
    
    #return the plausi value
    echo "${is_valid}"
    
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
    local is_ssh=false
    local local_url
    
    
    if [[ $# -eq 1 ]]; then
        local_url=${1}
        returnvalue=$(validate_param "false" "true" "${local_url}")
        echo "${returnvalue}" "${local_url}"
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
        ssh| -s)
            local_url="$2"
            is_local=false
            is_remote=true
            is_ssh=true
            shift;
            shift;
        ;;
        --yes | -y)
            info "SKIP QUESTION TRUE" "Skip Question Flag activated."
            SKIP_QUESTIONS="true"
        ;;
        help | -?)
            help
            shift;
            shift;
        ;;
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            error "INVALID FIRST PARAM" "Param needs to be 'local', 'ssh' or 'remote'. actual: ${1}"
            console_exit "Invalid First Param. Param needs to be 'local', 'ssh' or 'remote'"
        ;;
    esac
    
    returnvalue=$(validate_param "${is_local}" "${is_remote}" "${is_ssh}" "${local_url}")
    echo "${returnvalue}" "${local_url}"
}