#!/bin/bash
COMMENT=$2
echo ${COMMENT}
ROOTPATH=$1
alias cds='cds(){ cd ${ROOTPATH};ls; };cds'

function mipublish {
    commitCurBranch
}

function find_git_branch {
    local dir=. head
    until [ "$dir" -ef / ]; do
        if [ -f "$dir/.git/HEAD" ]; then
            head=$(< "$dir/.git/HEAD")
            if [[ $head = ref:\ refs/heads/* ]]; then
                git_branch="${head#*/*/}"
            elif [[ $head != '' ]]; then
                git_branch=" | (detached)"
            else
                git_branch=" | (unknow)"
            fi
            return
        fi
        dir="../$dir"
    done
    git_branch=''
}

function commitCurBranch {
    cds
    git pull
    git status
    git add .
    git commit -m "${COMMENT}"
    git push
    checkTestingBranch
}

function checkTestingBranch {
    find_git_branch
    echo "合并 "${git_branch}" 分支到testing分支..."
    git checkout testing
    git pull
    diff_msg=$(git merge ${git_branch})
    if [[ $diff_msg =~ "CONFLICT (content)" ]]; then
        echo 'conflict error!'
        exit 2
    else
        echo 'no conflict~'
    fi
    git status
    git add .
    git commit -m "${COMMENT}"
    git push
    #mitag
}

function mitag {
    git pull --tags
    local branch=$(git branch | sed -n '/\* /s///p')
    local new_tag=$(echo ${branch}-$(date +'%Y%m%d')-$(git tag -l "${branch}-$(date +'%Y%m%d')-*" | wc -l | xargs printf '%02d'))
    echo ${new_tag}
    git tag ${new_tag}
    git push origin $new_tag
}


# find_git_branch
# if [[ $git_branch =~ ^feature ]]; then
    mipublish
# else
#     echo '不能在除 feature 分支执行 npm run testing命令'
#     exit 1
# fi





