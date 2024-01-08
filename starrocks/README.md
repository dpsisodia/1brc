# CREDITS and REFERENCES:
https://github.com/ClickHouse/ClickBench/tree/main/starrocks

# 1 Billion Rows Challenge

To avoid dependecy on JDK21 a precreated data file measurement.txt was generated and loaded with source code. This sample uses it. 

## To start execute shell script 1bntest.sh. This will download StarRocks binary, configure one fe and one be, create db/table schema and load data using stream load and lastly perform the test.

```bash
# sh 1bntest.sh
```

## Clean Up

```bash
$ rm -rf StarRocks*

$ 
```
