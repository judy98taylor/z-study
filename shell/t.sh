#!/bin/bash

# git checkout RELEASE
# git pull
# git checkout -b 'feature-'${NAME}

# 当前时间
# date "+%Y-%m-%d %H:%M:%S"
# 当前分支名称
# git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3
# datetime=$(date "+%Y-%m-%d %H:%M:%S")
datetime=$(date "+%Y%m%d %H:%M:%S")
# git status
# git add --all
# git commit -m "save"
# git pull
# git push
# git checkout -b "dev$(date +%Y%m%d)"

# ""字符串！
# status="git status"
# ``执行命令
status=`git status`

# >> ；如果文件不存在，将创建新的文件，并将数据送至此文件；如果文件存在，则将数据添加在文件后面
# >  ；如果文件不存在，同上，如果文件存在，先将文件清空，然后将数据填入此文件
# echo $status > log.txt
# open log.txt

if [[ $status =~ "git add" ]]; then
  git add --all
  git commit -m "save$(date +%Y%m%d)"
  git pull
  git push
  echo -e "\033[42;37m push ok \033[0m"
else 
  echo -e “\033[41;37m !need git add \033[0m”
fi

