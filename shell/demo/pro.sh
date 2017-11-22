#!/bin/bash
set -e
COMMENT=${@:1}
echo ${COMMENT}
basepath=$(cd `dirname $0`; cd ..;pwd)

function commit(){
    git pull
    git status
    git add .
    git commit -m "${COMMENT}"
    git push
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
  if [[ ! $status =~ "nothing to commit" ]]; then
    echo "m-mi-com有未提交的文件"
    exit 2
  fi
}

find_git_branch 
if [[ ! $git_branch =~ "RELEASE" ]]; then
    echo "你不在RELEASE分支，请 git checkout RELEASE 在执行"
    exit 2
fi

cdMmicom
checkMaster
cd ${basepath}
sh build.sh 'pro'
cdMmicom
commit