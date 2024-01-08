# CREDITS and REFERENCES:
https://github.com/ClickHouse/ClickBench/tree/main/starrocks

# 1 Billion Rows Challenge

To avoid dependecy on JDK21 on test script. generation of data is step one which requires to be done manually before executing script in next step.
Data file measurement.txt is expected in same folder as starrocks. To create it install JDK21 and run generate script command as given below:

Gunnar provides a data generator that creates a billion row file. To run this generator, you’ll need Java 21, and the easiest way to get it is using sdkman(https://sdkman.io/install), which Robin suggests in his version of 1BRC.

$ sdk install java 21.0.1-zulu
$ sdk use java 21.0.1-zulu
Generate a One Billion Record CSV
These steps were taken from Gunnar’s GitHub repo.

Build the project using Apache Maven:

$ ./mvnw clean verify
Create the measurements file with 1B rows (just once):

$ ./create_measurements.sh 1000000000
This will take a few minutes. Attention: the generated file has a size of approx. 12 GB, so make sure to have enough disk space.


## To start test execute shell script 1bntest.sh. 
This will download StarRocks binary, configure one fe and one be, create db/table schema and load data using stream load and lastly perform the test.

```bash
# sh 1bntest.sh
```

## Clean Up

```bash
$ rm -rf StarRocks*

$ 
```
