#!/bin/bash
# Read and parse simple INI file

TMP_FILE="tmp.ini"
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
    filename="${1}"
    echo "creating file that will be parsed"
    sed 's/^\[.\+"\(.\+\)\"\]/[\1]/' ${filename} > ${TMP_FILE}
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

if [ "$#" -eq "1" ] && [ -f "$1" ]; then
    ret_value=$(preprocessing "$1")
    if [ -f "${TMP_FILE}"] && [[ ret_value == "true" ]]; then
        get_ini_sections "$filename"
        
        echo -n "Configuration description: "
        if [ -n "${configuration_main["description"]}" ]; then
            echo "${configuration_main["description"]}"
        else
            echo "missing"
        fi
        echo
        
        for section in $(read_ini_sections "${filename}"); do
            echo "[${section}]"
            for key in $(eval echo $\{'!'configuration_${section}[@]\}); do
                echo -e "  ${key} = $(eval echo $\{configuration_${section}[$key]\}) (access it using $(echo $\{configuration_${section}[$key]\}))"
            done
        done
    fi
    
else
    echo "missing INI file"
fi