#!/bin/bash
# use this
# Read and parse simple INI file
# Stop even, if a command in a pipe fails.
set -e -o pipefail

TMP_FILE="tmp.ini"

# will be added in mainfile deep_copy_submodules.sh 
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
    info "INFO PARSING INI" "parsing ${filename} into standardized format ini file: ${TMP_FILE}"
    
    sed 's/^\[.\+"\(.\+\)\"\]/[\1]/' ${filename} | sed 's/\-/_/g' > ${TMP_FILE}
    # clear invalid characters
    
    echo "true"
}



# Get INI section
read_ini_sections(){
    local filename="$1"
    gawk '{ if ($1 ~ /^\[/) section=tolower(gensub(/\[(.+)\]/,"\\1",1,$1)); configuration[section]=1 } END {for (key in configuration) { print key} }' ${filename}
}

# Get/Set all INI sections
get_ini_sections(){
    local filename="$1"
    
    sections="$(read_ini_sections $filename)"
    for section in $sections; do
        array_name="configuration_${section}"
        declare -g -A ${array_name}
    done
    eval $(gawk -F= '{
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
        }' ${filename}
    )
    
    
}

parse_ini() {
    # input: ini file (with git flavour)
    # output in global variables: parsed ini with $configuration_section[field]=value
    if [ "$#" -eq "1" ] && [ -f "$1" ]; then
        ret_value=$(preprocessing "$1")
        if [[ -f "${TMP_FILE}" ]] && [[ ${ret_value} == "true" ]] ; then
            
            filename="${TMP_FILE}"
            get_ini_sections "$filename"
            
            # echo -n "Configuration description: "
            # if [ -n "${configuration_main["description"]}" ]; then
            #     echo "${configuration_main["description"]}"
            # #else
            # echo "missing"
            #fi
            section_list=$(read_ini_sections "${filename}")

            info "INFO - Segments of Ini " "$(declare -p sections)"
            # for section in $(read_ini_sections "${filename}"); do
            #     echo "[${section}]"
            #     for key in $(eval echo $\{'!'configuration_${section}[@]\}); do
            #         echo -e "  ${key} = $(eval echo $\{configuration_${section}[$key]\}) (access it using $(echo $\{configuration_${section}[$key]\}))"
            #     done
            # done
        fi
    else
        echo "missing INI file"
    fi
}