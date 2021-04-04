#!/bin/bash
# use this
# Read and parse simple INI file
# Stop even, if a command in a pipe fails.
set -e -o pipefail

# temporary file name of the ini
TMP_FILE="tmp.ini"

# will be added in mainfile deep_copy_submodules.sh
# if you want to use that function without deep_copy, then you have to include log.sh
# source "log.sh"

# preprocessing
preprocessing() {
    
    # https://riptutorial.com/sed/example/8893/backreference
    # FSM Image: https://linuxhandbook.com/content/images/2020/07/sed-flowchart.png
    # https://linuxhandbook.com/sed-reference-guide/
    
    ## ^ = start of line
    ## \[, \] = escaped bracket
    ## \+ = escaped regular expression '+'
    ## (fyi: \\+ = '+')
    ## \" = escaped quote mark "
    ## \(, \) =  backreference group in regular expression matches
    ## (fyi: '()' = regexp group)
    ## \1 = first backreference (\n nth backreference), referred to the backreference group
    ## Does: standardize git .modules to a normal ini "[submodulename]"
    local filename="${1}"
    info "INFO PARSING INI" "parsing ${filename} into standardized format ini file: ${TMP_FILE_PATH}"
    
    # clear invalid characters
    sed 's/^\[.\+"\(.\+\)\"\]/[\1]/' "${filename}"  > "${TMP_FILE_PATH}" # | sed 's/\-/_/g'
    
    echo "true"
}



# Get INI section
read_ini_sections(){
    local filename="$1"
    gawk '{ if ($1 ~ /^\[/) section=tolower(gensub(/\[(.+)\]/,"\\1",1,$1)); configuration[section]=1 } END {for (key in configuration) { print key} }' "${filename}"
}

# Get/Set all INI sections
get_ini_sections(){
    local filename="$1"
    
    sections="$(read_ini_sections "$filename")"
    for section in $sections; do
        array_name="configuration_${section}"
        # BECAREFUL
        declare -g -A "${array_name}"
    done
    eval "$(gawk -F= '{
                    if ($1 ~ /^\[/)
                      section=tolower(gensub(/\[(.+)\]/,"\\1",1,$1))
                    else if ($1 !~ /^$/ && $1 !~ /^;/) {
                      gsub(/^[ \t]+|[ \t]+$/, "", $1);
                      gsub(/[\[\]]/, "", $1);
                      gsub(/^[ \t]+|[ \t]+$/, "", $2);
                      if (configuration[section][$1] == "")
                        configuration[section][$1]=$2
                      else
                        configuration[section][$1]=configuration[section][$1]" "$2}
                    }
                    END {
                      for (section in configuration)
                        for (key in configuration[section]) {
                          section_name = section
                          gsub( "-", "_", section_name)
                          print "configuration_" section_name "[\""key"\"]=\""configuration[section][key]"\";"
                        }
        }' "${filename}"
    )"
    
    
}
clean_up_ini() {
    # clean up actions
    if [[ -f "${TMP_FILE_PATH}" ]]; then
        info "CLEANUP" "Cleaning up: ${TMP_FILE_PATH}"
        # Using :? will cause the command to fail if the variable is null or unset. Similarly, you can use :- to set a default value if applicable.
        rm "${TMP_FILE_PATH:?}"
    fi
    TMP_FILE=""
    ret_value=""
    filename=""
}
#trap clean_up_ini EXIT

parse_ini() {
    # input: ini file (with git flavour)
    # output in global variables: parsed ini with $configuration_section[field]=value
    if [ "$#" -eq "1" ] && [ -f "$1" ]; then
        if [[ -d "${TMP_PATH}" ]]; then
            # put the tmp ini file into the tmp folder
            TMP_FILE_PATH=${TMP_PATH:?}/${TMP_FILE}
            ret_value=$(preprocessing "$1")
        fi
        if [[ -f "${TMP_FILE_PATH}" ]] && [[ ${ret_value} == "true" ]] ; then
            filename="${TMP_FILE_PATH}"
            get_ini_sections "$filename"
            # shellcheck disable=SC2034
            # shellcheck disable=SC2207
            section_list=($(read_ini_sections "${filename}"))
            
            info "INFO - Segments of Ini " "$(declare -p sections)"
        else
            error "ERROR TMP INI FILE" "Can't find tmp ini on path: ${TMP_FILE_PATH} or preprocessing failed (ret_value: ${ret_value})."
            console_exit "Problem with temporary ini file creation"
        fi
        echo "${section_list[@]}"
        #clean_up_ini
    elif [ "$#" -gt "1" ]; then
         error "ERROR TMP INI FILE" "Can only parse ONE file at a time. Please take only one file as input"
        console_exit "error with INI file - multiple files but only one expected"
    elif [ "$#" -eq "0" ]; then
         error "ERROR TMP INI FILE" "No ini file given as input. Please put the ini file as first (and only!) parameter"
        console_exit "error with INI file - no file to parse given"
    else
        error "ERROR TMP INI FILE" "Can't find ini on path: ${TMP_FILE_PATH} or ${1}"
        console_exit "error with INI file"
    fi
}


parse_ini_without_preparsing() {
     if [ "$#" -eq "1" ] && [ -f "$1" ]; then
            filename="${1}"
            get_ini_sections "$filename"
            # shellcheck disable=SC2034
            # shellcheck disable=SC2207
            section_list=($(read_ini_sections "${filename}"))
            
            info "INFO - Segments of Ini " "$(declare -p sections)"
        echo "${section_list[@]}"
        #clean_up_ini
    elif [ "$#" -gt "1" ]; then
         error "ERROR TMP INI FILE" "Can only parse ONE file at a time. Please take only one file as input"
        console_exit "error with INI file - multiple files but only one expected"
    elif [ "$#" -eq "0" ]; then
         error "ERROR TMP INI FILE" "No ini file given as input. Please put the ini file as first (and only!) parameter"
        console_exit "error with INI file - no file to parse given"
    else
        error "ERROR TMP INI FILE" "Can't find ini on path: ${TMP_FILE_PATH} or ${1}"
        console_exit "error with INI file"
    fi
}
## auxilary methods
give_value() {
    # don't question why this needs to be written so..
    # it does its job
    # shellcheck disable=SC2046
    echo -e $(eval echo $\{configuration_"${1}"["$2"]\})
}

print_ini() {
    for section in "${section_list[@]}"; do
        echo "[${section}]"
        for key in $(eval echo $\{'!'configuration_"${section}"[@]\}); do
            echo -e "  ${key} = $(eval echo $\{configuration_"${section}"[$key]\}) " #(access it using $(echo $\{configuration_${section}[$key]\}))"
        done
    done
}

print_ini_auto() {
    parse_ini "$1" > /dev/null
    print_ini
    clean_up_ini
}


