CREATE TABLE measurements (
    city STRING NOT NULL, 
    temp decimal NOT NULL 
)  
DUPLICATE KEY (city, temp) 
DISTRIBUTED BY HASH(city) BUCKETS 192
PROPERTIES ( "replication_num"="1");
