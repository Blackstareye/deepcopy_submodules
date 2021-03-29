#!/usr/bin/env bash
util_grep_test_result_content() {
    # 1 : testresult file
    # 2 : test ini file
    local reader="false"
    while IFS=, read -r y
    do
        if [[ "$y" =~ .*"$2".* ]]; then
            reader="true"
            continue;
            elif [[ "$y" =~ ^"=".* && "$reader" == "true" ]]; then
            break;
        fi
        if [[ "$reader" == "true" ]]; then
            echo "$y"
        fi
    done < "$1"
}

changeDir() {
    # let cwd be the actual  directory
    cd ${1}
    CWD_PATH="$(pwd)"
}


make_TMP_DIR() {
    if [[ ! -d "${1}" ]]; then
        mkdir -p ${1}
    fi
}

check_path_file() {
    if [[ -f "${1}" ]]; then
        return 0
    else
        return 1
    fi
}
check_path_dir() {
  if [[ -d "${1}" ]]; then
        return 0
    else
        return 1
    fi
}

check_not_null() {
  if [[ -n "${1}" ]]; then
        return 0
    else
        return 1
    fi
}

check_null() {
  if [[ -z "${1}" ]]; then
        return 0
    else
        return 1
    fi
}

#util_grep_test_result_content $1 $2