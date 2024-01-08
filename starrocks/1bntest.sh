#!/bin/bash
#Adapted from https://github.com/ClickHouse/ClickBench/tree/main/starrocks
set -ex
VERSION=3.0.0-preview
DOWNLOAD_URL=https://releases.starrocks.io/starrocks/StarRocks-3.0.0-preview.tar.gz

# Try to stop and remove it first if execute this script multiple times
set +e
"StarRocks-${VERSION}"/fe/bin/stop_fe.sh
"StarRocks-${VERSION}"/be/bin/stop_be.sh
rm -rf "StarRocks-${VERSION}"
set -e

#Install
wget -c -O StarRocks-${VERSION}.tar.gz $DOWNLOAD_URL
tar zxvf StarRocks-${VERSION}.tar.gz
tar zxvf measurements.tar.gz
cd StarRocks-${VERSION}/

# Install dependencies
sudo yum install -y java-1.8.0-openjdk-devel.x86_64 mysql

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk/
export PATH=$JAVA_HOME/bin:$PATH

# Create directory for FE and BE
IPADDR=`hostname -I`
echo $IPADDR
export STARROCKS_HOME=`pwd`
mkdir -p meta storage

# Start Frontend
echo "meta_dir = ${STARROCKS_HOME}/meta " >> fe/conf/fe.conf
fe/bin/start_fe.sh  --daemon

# Start Backend
echo "storage_root_path = ${STARROCKS_HOME}/storage" >> be/conf/be.conf
be/bin/start_be.sh --daemon

# Setup cluster
# wait some seconds util fe can serve
sleep 20
mysql -h 127.0.0.1 -P9030 -uroot -e "ALTER SYSTEM ADD BACKEND '${IPADDR}:9050' "
# wait some seconds util be joins
sleep 10

# Prepare Data - already created data and uploaded to avoid jdk dependency
cd ../


# Create Table
mysql -h 127.0.0.1 -P9030 -uroot -e "CREATE DATABASE sample"
mysql -h 127.0.0.1 -P9030 -uroot sample < create.sql

# Load Data
START=$(date +%s)
echo "Start to load data..."$date
curl --location-trusted \
    -u root: \
    -H "timeout:259200" \
    -T "measurements.txt" \
    -H "label:${START}" \
    -H "columns: city,temp" \
    -H "column_separator:;" \
    http://localhost:8030/api/sample/measurements/_stream_load
END=$(date +%s)
LOADTIME=$(echo "$END - $START" | bc)
echo "Load data costs $LOADTIME seconds"

# Dataset contains about 13GB of data when the import is just completed.
# This is because the trashed data generated during the compaction process.
# After about tens of minutes, when the gc is completed, the system includes about 8.5GB of data.
du -bcs StarRocks-${VERSION}/storage/
# Dataset contains 1bi rows
mysql -h 127.0.0.1 -P9030 -uroot sample -e "SELECT count(*) FROM measurements"

# Run queries
./run.sh 2>&1 | tee run.log

sed -r -e 's/query[0-9]+,/[/; s/$/],/' run.log
