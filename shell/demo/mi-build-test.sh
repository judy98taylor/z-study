#!/bin/bash
set -e
COMMENT=${@:1}
echo ${COMMENT}
basepath=$(cd `dirname $0`; cd ..;pwd)

if [ ! -n "$COMMENT" ]; then
    echo "请输入git commit message"
    echo "eg: sh shell/mi-build-test.sh 'commit Message'"
    echo "\r"
    exit 3
fi

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

function commit(){
    git pull
    git status
    git add .
    git commit -m "${COMMENT}"
    git push
}

function commitCurBranch {
    cd ${basepath}
    commit
    checkTestingBranch
}

function checkTestingBranch {
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
    cdMmicom
    checkMaster
    cd ${basepath}
    sh build.sh 'test'
    cdMmicom
    commit
    mitag
    cd ${basepath}
    git checkout $git_branch
}

function mitag {
    git pull --tags
    local branch=$(git branch | sed -n '/\* /s///p')
    local new_tag=$(echo ${branch}-$(date +'%Y%m%d')-$(git tag -l "${branch}-$(date +'%Y%m%d')-*" | wc -l | xargs printf '%02d'))
    echo ${new_tag}
    git tag ${new_tag}
    git push origin $new_tag
}

function cdMmicom(){
  cd ${basepath}
  cd ..
  cd m-mi-com
  echo "切换到m-mi-com"

}

function checkMaster(){
  git checkout master
  git pull
  status=`git status`
  if [[ $status =~ "Already up-to-date" ]]; then
    echo "有未提交的文件"
    exit 2
  fi
}
mipublish