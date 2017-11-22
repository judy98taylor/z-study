#!bin/bash

# 你写的每个脚本都应该在文件开头加上set -e,这句语句告诉bash如果任何语句的执行结果不是true则应该退出。这样的好处是防止错误像滚雪球般变大导致一个致命的错误，而这些错误本应该在之前就被处理掉。如果要增加可读性，可以使用set -o errexit，它的作用与set -e相同。
set -e

# script 的功能；
# script 的版本資訊；
# script 的作者與聯絡方式；
# script 的版權宣告方式；
# script 的 History (歷史紀錄)；
# script 內較特殊的指令，使用『絕對路徑』的方式來下達；
# script 運作時需要的環境變數預先宣告與設定。

# echo ${SHELL}
# echo ${PATH}
# echo ${HOME}

# 执行的命令
echo '$0' $0
# 执行命令 接收到的全部参数
echo '$@' $@
# 第一个参数
echo '$1' $1
# 除去第一个参数的所有参数
echo '${@:1}' ${@:1}

shuru=$1
if [ "$1" == "0" ];then
  echo '$1 is 0'
  # exit 0
elif [ "$shuru" == "1" ]; then
  echo '$1 is 1'
  # exit 0
else
  echo '$1不是0也不是1'
  echo '$1是'$1
  # exit 0
fi

case $1 in 
  "0")
    echo 'is 0'
    ;;
  "1")
    echo 'is 1'
    ;;
  *)
    exit 1
    ;;
esac

# exit命令使shell退出.参数n表示带返回值n退出
# 没有n的话,则返回最后一个命令执行的后的状态,在shell
# 被终止前,将执行exit的陷阱
# 这个n值存放在$?中,一般来说,0表示最后命令执行成功,1表示没有找到参数,127表示$0错误,至于2,还要根据脚本的情况具体分析

# 一個指令的執行成功與否，可以使用 $? 這個變數來觀察
echo $?

open .
# open(https://chaos.pf.xiaomi.com/deploy/projects/667/publish)

# 包含
if [[ $1 =~ $2 ]];then
  echo $1'包含'$2 
fi
# 不包含
if [[ ! $1 =~ $2 ]];then
  echo $1'不包含'$2 
fi

# if [ str1 = str2 ]　　　　　  当两个串有相同内容、长度时为真 
# if [ str1 != str2 ]　　　　　 当串str1和str2不等时为真 
# if [ -n str1 ]　　　　　　 当串的长度大于0时为真(串非空) 
# if [ -z str1 ]　　　　　　　 当串的长度为0时为真(空串) 
# if [ str1 ]　　　　　　　　 当串str1为非空时为真
# shell 中利用 -n 来判定字符串非空。

if [ ! -n "$1" ]; then
    echo '请输入$1'
    echo "eg: sh shell/test.sh s1"
    # 回车
    echo "\r"
    # exit 3
fi

if [ -n $1 ]; then
    echo $1
fi

# if [ -n $ARGS  ]
# 不管传不传参数，总会进入if里面。 原因：因为不加“”时该if语句等效于if [ -n ]，shell 会把它当成if [ str1 ]来处理，-n自然不为空，所以为正