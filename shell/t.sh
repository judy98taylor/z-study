#!/bin/bash

# function find_git_branch {
#     local dir=. head
#     until [ "$dir" -ef / ]; do
#         if [ -f "$dir/.git/HEAD" ]; then
#             head=$(< "$dir/.git/HEAD")
#             if [[ $head = ref:\ refs/heads/* ]]; then
#                 git_branch="${head#*/*/}"
#             elif [[ $head != '' ]]; then
#                 git_branch=" | (detached)"
#             else
#                 git_branch=" | (unknow)"
#             fi
#             return
#         fi
#         dir="../$dir"
#     done
#     git_branch=''
# }

# copy to clipboard
# echo $@ 
# echo $@ | pbcopy
# copy from clipboard
# echo "$(pbpaste -Prefer text)"

# echo $PWD
# code $PWD