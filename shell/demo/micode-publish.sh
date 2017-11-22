#!/bin/bash
COMMENT=$*
echo ${COMMENT}
function mipublish {
    echo "publish code to test envirment...\n"
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
    cd ../../../..
    git pull
    git status
    git add .
    git commit -m "${COMMENT}"
    git push
    checkMasterBranch
}

function checkMasterBranch {
    find_git_branch
    echo "合并 "${git_branch}" 分支到master分支..."
    git checkout master
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
    git checkout RELEASE
    git pull
    diff_msg=$(git merge master)
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

find_git_branch
if [[ $git_branch =~ ^feature ]]; then
    echo 'feature'
    mipublish
elif [[ $git_branch =~ "master" ]]; then
    echo 'master'
    mipublish
else
    echo '不能在除 feature、master 分支执行 npm run deploy 命令'
    exit 1
fi








