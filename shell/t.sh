#!/bin/bash

# git checkout RELEASE
# git pull
# git checkout -b 'feature-'${NAME}

# 当前时间
# date "+%Y-%m-%d %H:%M:%S"
# 当前分支名称
# git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3
DATE=$(+%Y-%m-%d %H:%M:%S)
git status
git add --all
git commit -m "zxd $DATE"
git pull
git checkout -b "dev$(%Y%m%d%H%M%S)"