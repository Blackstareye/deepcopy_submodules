#!/usr/bin/env bash

isolated_operation() {
    # an isolated operation is a operation with great a sideeffect
    # 1 param to be executed command
    # 2 call function if command failed
    error=$(eval "$1" 2>&1 > /dev/null)
    if [[ "$?" -ne 0 ]]; then
        eval '$2 $error'
    fi
}

# revert_cat() {
#     echo "called revert cat with \"$*\" "
# }



# # template for isolation call
# tmp_string="$*"
# command="cat"
# new_string="$command $(echo "$tmp_string")"
# echo "$new_string"
# isolated_operation "$new_string" "revert_cat"

