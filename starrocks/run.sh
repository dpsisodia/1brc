#!/bin/bash
#Adapted from https://github.com/ClickHouse/ClickBench/tree/main/starrocks
TRIES=3
QUERY_NUM=0
touch result.csv
truncate -s0 result.csv

cat queries.sql | while read -r query; do
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

    echo -n "query${QUERY_NUM}," | tee -a result.csv
    for i in $(seq 1 $TRIES); do
        RES=$(mysql -vvv -h127.1 -P9030 -uroot sample -e "${query}" | perl -nle 'print $1 if /\((\d+\.\d+)+ sec\)/' ||:)

        echo -n "${RES}" | tee -a result.csv
        [[ "$i" != $TRIES ]] && echo -n "," | tee -a result.csv
    done
    echo "" | tee -a result.csv

    QUERY_NUM=$((QUERY_NUM + 1))
done;
