#!/bin/bash

# 你写的每个脚本都应该在文件开头加上set -e,这句语句告诉bash如果任何语句的执行结果不是true则应该退出。这样的好处是防止错误像滚雪球般变大导致一个致命的错误，而这些错误本应该在之前就被处理掉。如果要增加可读性，可以使用set -o errexit，它的作用与set -e相同。
set -e

NAME=${@:1}
echo ${NAME}


status=`git status`
if [[ ! $status =~ "nothing to commit" ]]; then
    echo "有未提交的文件"
    exit 2
fi

if [ ! -n "$NAME" ]; then
    echo "请输入feature name"
    echo "eg: sh shell/feature.sh name"
    echo "\r"

    exit 3
fi

git checkout RELEASE
git pull
git checkout -b 'feature-'${NAME}
