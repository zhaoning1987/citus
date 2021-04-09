#!/bin/bash

[[ $# -lt 2 ]] && echo "usage seed tgt" && exit -1

f=$1
tgt=$2

while read line; do
    [[ "$line" == "" ]] && continue
    echo "$line"
    func=$(echo $line | awk '{print $1}')
    lno=$(echo $line | awk '{print $2}')
    elno=$(expr $lno + 10)

    found=0
    while read l; do
        lno=$(expr $lno + 1)
        [[ "${l: -1}" == ';' ]] && break
        [[ "${l:0:1}" == '{' ]] && found=1 && break
    done < <(sed -n "${lno},${elno}p" $tgt)

    [[ $found -eq 0 ]] && echo "skip $line ...." && continue

    sed -i "$lno i elog(INFO, \"TTT $tgt:$func\");" $tgt
done < $f

#sed -i '0,/#include/{s/#include/#include\ "utils\/elog.h"\n#include/}' $tgt
tac $tgt | sed '0,/#include/{s/#include/#include\ "utils\/elog.h"\n#include/}' | tac > ${tgt}.tmp
mv ${tgt}.tmp $tgt
