#!/usr/bin/env bash
# this is the stub for git operations

## called from SCRIPT_PATH
# shellcheck disable=SC1091
source "tst/testhelper.sh"

git() {
    # 3 ones
    argument=("$@")
    # NOTE last one will be sliced off
    
    # 3 ones
    echo "3: ${argument[*]:0:3}"
    case "${argument[@]:0:3}" in
        "rm -r --cached")
            echo "${argument[3]}"
            check_path_dir "${argument[3]}"
            return $?
        ;;
        
        *)
            
        ;;
    esac
    
    # 2 ones
    echo "2: ${argument[*]:0:2}"
    case "${argument[@]:0:2}" in
        "submodule add")
            #check_path_dir "$3"
            check_not_null "${argument[2]}"
            return $?
        ;;
        
        "remote add")
            check_not_null "${argument[2]}" && check_not_null "${argument[3]}"
            return $?
        ;;
        "commit -m")
            check_not_null "${argument[2]}"
            return $?
        ;;
        *)
            
        ;;
    esac
    
    # 1 ones
    echo "1: ${argument[*]:0:1}"
    case "${argument[@]:0:1}" in
        "push")
            check_not_null "${argument[1]}" && check_not_null "${argument[1]}"
            return $?
        ;;
        *)
        ;;
    esac
}

rm() {
    # rm -rf
    # rm
    if [[ "$#" == 1 ]]; then
        check_path_file "$1"
    else 
        check_path_file "$2"
    fi
}

sed() {
    # sed -i 1 2
    check_path_file "$3"
    return $?
}


test_foo () {
    echo "successfully injected"
}

