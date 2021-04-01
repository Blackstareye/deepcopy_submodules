#!/usr/bin/env bash
# Submodule of deep_copy_submodules
# contains all operations that are git related


# edit the git modules with the new urls
# following this guide
# https://www.w3docs.com/snippets/git/how-to-remove-a-git-submodule.html
# TODO NOTE: TOBETESTED

# isolated_operation() {
#     # an isolated operation is a operation with a sideeffect
#     # 1 param to be executed command
#     # 2 call function if command failed
#     error=$(eval "$1")
#     if [[ "$?" -ne 0 ]]; then
#         tmp_string=$($2)
#         eval "$tmp_string"
#     fi
# }
# load lib
source "isolation.sh"

# NOTE AND TODO TO BE TESTED
# critical tasks need to be treat with '{ error "FAILURE USING CD" " ${1} was not sucessful"; console_exit; }'
task_add_submodules_local() {
    if [[ $# -ne 1 ]]; then
        { error "Adding Submodule  Local Task - PARAMS Size is not 1" "PARAMS Size is not 1 it is: $#"; return 1; }
    fi
    cd "${1}" || { error "FAILURE USING CD" " ${1} was not sucessful"; console_exit; }
    local remote_url="${URL_ARR[1]}/${section}.git"
    # shellcheck disable=SC2154
    for section in "${section_list[@]}"; do
        info "ADDING SUBMODULE LOCALLY"  "SUBMODULE: [${section}] with path: ${1}"
        remote_url="${URL_ARR[1]}/${section}.git"
        git submodule add "${remote_url}" || { error "FAILURE USING submodule add ${remote_url} was not sucessful"; return 1; }
        git commit -m "Added the submodule ${section} to the project." || { error "FAILURE USING git commit -m  ${section}  was not sucessful"; return 1; }
    done
}
task_clone_from_remote() {
    # TODO realize clone
    echo "TODO"
    # if [[ $# -ne 2 ]]; then
    #     { error "Cloning from Remote Task - PARAMS Size is not 2" "PARAMS Size is not 1 it is: $#"; return 1; }
    # fi
    # #cd "${1}" || { error "FAILURE USING CD" " ${1} was not sucessful"; console_exit; }
    # local remote_url="${URL_ARR[1]}/${section}.git"
    # # shellcheck disable=SC2154
    # for section in "${section_list[@]}"; do
    #     info "ADDING SUBMODULE LOCALLY"  "SUBMODULE: [${section}] with path: ${1}"
    #     remote_url="${URL_ARR[1]}/${section}.git"
    #     git submodule add "${remote_url}" || { error "FAILURE USING submodule add ${remote_url} was not sucessful"; return 1; }
    #     git commit -m "Added the submodule ${section} to the project." || { error "FAILURE USING git commit -m  ${section}  was not sucessful"; return 1; }
    # done
}

task_push_changes() {
    if [[ $# -ne 1 ]]; then
        { error "Push Changes Task - PARAMS Size is not 1" "PARAMS Size is not 1 it is: $#"; return 1; }
    fi
    cd "${1}"  || { error "FAILURE USING CD" " ${1} was not sucessful"; console_exit; }
    local remote_url="${URL_ARR[1]}/${BASE_PATH}.git"
    info "PUSH Changes of parent git repo"  "pushing local ${1} to ${remote_url}"
    git remote add "${GIT_REMOTE_NAME}" "${remote_url}"  || { error "FAILURE USING remote add  ${GIT_REMOTE_NAME} ${remote_url} was not sucessful"; return 1; }
    git push "${GIT_REMOTE_NAME}" "${GIT_REMOTE_BRANCH}"  || { error "FAILURE USING git push  ${GIT_REMOTE_NAME} ${GIT_REMOTE_BRANCH} was not sucessful"; return 1; }
    info "PUSH Changes of parent git repo"  "Done pushing"
}


task_remove_submodule() {

    if [[ $# -ne 1 ]]; then
        { error "Remove Submodule  Task - PARAMS Size is not 1" "PARAMS Size is not 1 it is: $#"; return 1; }
    fi
    # revert tasks
    #
    local submodule=""
    
    # change to base git
    cd "${1}"  || { error "FAILURE USING CD" " ${1} was not sucessful"; return 1; }
    
    local removepath="${1}/${submodule}"
    
    info "RM gitmodules" "Removing ${1}/${GIT_MODULE_FILE}"
    
    # remove .gitmodules
    rm "${1}/${GIT_MODULE_FILE}" || { error "FAILURE USING RM" " ${1}/${GIT_MODULE_FILE} was not sucessful"; return 1; }
    
    
    # edit .config
    local gitconfig_file="${1}/.git/config"
    local git_module_folder="${1}/.git/modules/"
    info "SED editing git config" "Removing Submodule entries in ${gitconfig_file}"
    # which  ,+2d -> delete line + 2 following lines
    sed -i '/\[submodule .*\]/,+2d' "${gitconfig_file}"  || { error "FAILURE USING sed" " ${gitconfig_file} was not sucessful"; return 1; }
    # unstaging submodule cache
    # shellcheck disable=SC2154
    for section in "${section_list[@]}"; do
        info "GITMODULE REMOVING - SUBMODULE"  "[${section}]"
        submodule="${section}"
        
        # remove submodule folder
        removepath="${1}/${submodule}/"
        info "GITMODULE REMOVING - SUBMODULE Remove"  "[${section}] Remove Submodule folder in ${removepath}"
        git rm -r --cached "${removepath}"  || { error "FAILURE USING git rm -r --cached" " ${removepath} was not sucessful"; return 1; }
        info "GITMODULE REMOVING - SUBMODULE Remove"  "[${section}] Remove Submodule Cache folder in ${git_module_folder}/${section}"
        rm -rf "${git_module_folder:?}/${section:?}"  || { error "FAILURE USING RM -rf" " ${git_module_folder:?}/${section:?} was not sucessful"; return 1; }
        
        # commit changes
        info "GITMODULE REMOVING - Commit changes"  "[${section}] Commit Changes"
        git commit -m "Removed submodule ${section}"  || { error "FAILURE USING git commit" " ${section} was not sucessful"; return 1; }
        
        # remove submodule folder
        info "GITMODULE REMOVING - Remove submodule folder"  "[${section}] remove folder: ${removepath}"
        rm -rf  "${removepath}"  || { error "FAILURE USING RM -rf" " ${removepath} was not sucessful"; return 1; }
    done
    info "GITMODULE REMOVING" "Done Removing (${section_list[*]})"
}


task_add_submodules_new_remote() {
    if [[ $# -ne 1 ]]; then
        { error "Add Submodules to new Remote Task - PARAMS Size is not 1" "PARAMS Size is not 1 it is: $#"; return 1; }
    fi
    local remote_url="${URL_ARR[1]}/${section}.git"
    for section in "${section_list[@]}"; do
        info "PUBLISHING TO NEW REMOTE"  "SUBMODULE: [${section}] changing directory ${1}/${section}"
        cd "${1}/${section}" || { error "FAILURE USING CD" " ${1}/${section} was not sucessful"; console_exit; }
        remote_url="${URL_ARR[1]}/${section}.git"
        info "PUBLISHING TO NEW REMOTE"  "SUBMODULE: [${section}] with url: ${remote_url}"
        git remote add "${GIT_REMOTE_NAME}" "${remote_url}" || { error "FAILURE USING git remote add" " ${GIT_REMOTE_NAME} was not sucessful"; return 1; }
        info "PWD LOCATION" "$(pwd)"
        git push "${GIT_REMOTE_NAME}" "${GIT_REMOTE_BRANCH}" || { error "FAILURE USING git push  ${GIT_REMOTE_NAME} ${GIT_REMOTE_BRANCH} was not sucessful"; return 1; }
    done
}

## reverts



revert_push_changes() {
    info "REVERT push_changes" "Reverting task 'pushing changes'"
    if [[ "${CREATE_TMP_FOLDER}" == "true" &&  -d "${TMP_PATH}" ]]; then
        rm -rf "${TMP_PATH}"
    fi
    error "GIT PUSH CHANGES FAILED" "Git Operation : Push Task was not possible ${1}"
    console_exit "Git Operation : Push Task was not possible ${1}"
}
revert_task_add_submodules_local() {
    info "REVERT task_add_submodules_local" "Reverting adding submodule to local copy"
    if [[ "${CREATE_TMP_FOLDER}" == "true" &&  -d "${TMP_PATH}" ]]; then
        rm -rf "${TMP_PATH}"
    fi
    
    error "GIT ADD SUBMODULE LOCAL FAILED" "Git Operation : Adding (local) Task was not possible ${1}"
    console_exit "Git Operation : Adding (local) Task was not possible ${1}"
}

revert_task_add_submodules_new_remote() {
    info "REVERT add_submodules_new_remote" "Reverting adding submodules and abort task"
    if [[ "${CREATE_TMP_FOLDER}" == "true" &&  -d "${TMP_PATH}" ]]; then
        rm -rf "${TMP_PATH}"
    fi
    
    error "GIT ADD SUBMODULE FAILED" "Git Operation : Adding Task was not possible ${1}"
    console_exit "Git Operation : Adding Task was not possible ${1}"

}


revert_task_remove_submodules() {
    info "REVERT REMOVE SUBMODULES" "Reverting Submodule and abort task"
    if [[ "${CREATE_TMP_FOLDER}" == "true" &&  -d "${TMP_PATH}" ]]; then
        rm -rf "${TMP_PATH}"
    fi
    
    error "GIT REMOVE SUBMODULE FAILED" "Git Operation : Removing Task was not possible ${1}"
    console_exit "Git Operation : Removing Task was not possible ${1}"
}
remove_submodules() {
    # template for isolation call
    tmp_string="$*"
    command="task_remove_submodule"
    new_string="$command $("$tmp_string")"
    #echo "$new_string"
    isolated_operation "$new_string" "revert_task_remove_submodules"
}

# NOTE AND TODO TO BE TESTED
add_submodules_new_remote() {
    # template for isolation call
    tmp_string="$*"
    command="task_add_submodules_new_remote"
    new_string="$command $("$tmp_string")"
    #echo "$new_string"
    isolated_operation "$new_string" "revert_task_add_submodules_new_remote"
}

# NOTE AND TODO TO BE TESTED
add_submodules_local() {
    # template for isolation call
    tmp_string="$*"
    command="task_add_submodules_local"
    new_string="$command $("$tmp_string")"
    #echo "$new_string"
    isolated_operation "$new_string" "revert_task_add_submodules_local"
}
push_changes() {
    # template for isolation call
    tmp_string="$*"
    command="task_push_changes"
    new_string="$command $("$tmp_string")"
    #echo "$new_string"
    isolated_operation "$new_string" "revert_push_changes"
}




    # local submodule=""
    
    # # change to base git
    # cd "${1}"  || { error "FAILURE USING CD" " ${1} was not sucessful"; console_exit; }
    
    # local removepath="${1}/${submodule}"
    
    # info "RM gitmodules" "Removing ${1}/${GIT_MODULE_FILE}"
    
    # # remove .gitmodules
    # rm "${1}/${GIT_MODULE_FILE}"
    
    
    # # edit .config
    # local gitconfig_file="${1}/.git/config"
    # local git_module_folder="${1}/.git/modules/"
    # info "SED editing git config" "Removing Submodule entries in ${gitconfig_file}"
    # # which  ,+2d -> delete line + 2 following lines
    # sed -i '/\[submodule .*\]/,+2d' "${gitconfig_file}"
    # # unstaging submodule cache
    # # shellcheck disable=SC2154
    # for section in "${section_list[@]}"; do
    #     info "GITMODULE REMOVING - SUBMODULE"  "[${section}]"
    #     submodule="${section}"
    
    #     # remove submodule folder
    #     removepath="${1}/${submodule}"
    #     info "GITMODULE REMOVING - SUBMODULE Remove"  "[${section}] Remove Submodule folder in ${removepath}"
    #     git rm -r --cached "${removepath}"
    #     info "GITMODULE REMOVING - SUBMODULE Remove"  "[${section}] Remove Submodule Cache folder in ${git_module_folder}/${section}"
    #     rm -rf "${git_module_folder:?}/${section:?}"
    
    #     # commit changes
    #     info "GITMODULE REMOVING - Commit changes"  "[${section}] Commit Changes"
    #     git commit -m "Removed submodule ${section}"
    
    #     # remove submodule folder
    #     info "GITMODULE REMOVING - Remove submodule folder"  "[${section}] remove folder: ${removepath}"
    #     rm -rf  "${removepath}"
    # done
    # info "GITMODULE REMOVING" "Done Removing (${section_list[*]})"
#}

# # NOTE AND TODO TO BE TESTED
# add_submodules_new_remote() {
    
#     local remote_url="${URL_ARR[1]}/${section}.git"
#     for section in "${section_list[@]}"; do
#         info "PUBLISHING TO NEW REMOTE"  "SUBMODULE: [${section}] changing directory ${1}/${section}"
#         cd "${1}/${section}" || { error "FAILURE USING CD" " ${1}/${section} was not sucessful"; console_exit; }
#         remote_url="${URL_ARR[1]}/${section}.git"
#         info "PUBLISHING TO NEW REMOTE"  "SUBMODULE: [${section}] with url: ${remote_url}"
#         git remote add "${GIT_REMOTE_NAME}" "${remote_url}"
#         info "PWD LOCATION" "$(pwd)"
#         git push "${GIT_REMOTE_NAME}" "${GIT_REMOTE_BRANCH}"
#     done
# }

# # NOTE AND TODO TO BE TESTED
# add_submodules_local() {
#     cd "${1}" || { error "FAILURE USING CD" " ${1} was not sucessful"; console_exit; }
#     local remote_url="${URL_ARR[1]}/${section}.git"
#     for section in "${section_list[@]}"; do
#         info "ADDING SUBMODULE LOCALLY"  "SUBMODULE: [${section}] with path: ${1}"
#         remote_url="${URL_ARR[1]}/${section}.git"
#         git submodule add "${remote_url}"
#         git commit -m "Added the submodule ${section} to the project."
#     done
# }

# push_changes() {
#     cd "${1}"  || { error "FAILURE USING CD" " ${1} was not sucessful"; console_exit; }
#     local remote_url="${URL_ARR[1]}/${BASE_PATH}.git"
#     info "PUSH Changes of parent git repo"  "pushing local ${1} to ${remote_url}"
#     git remote add "${GIT_REMOTE_NAME}" "${remote_url}"
#     git push "${GIT_REMOTE_NAME}" "${GIT_REMOTE_BRANCH}"
#     info "PUSH Changes of parent git repo"  "Done pushing"
# }