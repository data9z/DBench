## Sysbench

**Starting with 1-2-3 (PostgreSQL as example)**  

* Linux local variables: $dbip,  $dbport, $dbuser, etc.

### Step 1:  create Database

```shell
$ psql -h $dbip -p $dbport  -U $dbuser -W -c "CREATE DATABASE t_sysbench";
```

### Step 2: prepare Data: 10 tables, each with 10M rows

```shell
sysbench --db-driver=pgsql --pgsql-host="$dbip" --pgsql-port="$dbport" --pgsql-user="$dbuser" --pgsql-password="$pw"  --pgsql-db=t_sysbench --table_size=10000000 --tables=10 --events=0 --time=600  --threads=$i --percentile=95 --report-interval=60 oltp_read_write prepare
```

### III. Runs

Seven 10-minutes run of oltp_read_write with with different # of concurrent threads, with the focus on TPS, QPS, P95 latency and the CPU usage of the cloud database.

| Name             | Value |
| :---------------- | :------: | 
| scenario        |  oltp\_read\_write   | 
| concurrent threads        |  2,4,8,16,32,64,128   |
| latency           |   P95   |  
| cycle           |   600s   |  
| tables | 10   | 
| table size | 10,000,000   | 

* Note1: adjust latency to P99 depending on your user scenario
* Note2: While runs withconcurrency at 2,4,8 help to damonstate the linerage and stability of a DB system, feel free to skip them if only to figure the optimal output.

```shell
#!/bin/bash

# Pls modify accordingly
ofile="sysBench_result"
dbip="1.0.0.0"
dbport="5432"
dbuser="postgres"
pw="notGoingToTellyou"

for ((i=2; i<=128; i=i*2)) 
do 
	echo "Thread = $i"
	echo "######----- $(date) -----######" &>> "$ofile"
	echo "Thread = $i" &>> "$ofile"
	sysbench --db-driver=pgsql --pgsql-host="$dbip" --pgsql-port="$dbport" --pgsql-user="$dbuser" --pgsql-password="$pw"  --pgsql-db=t_sysbench --table_size=10000000 --tables=10 --events=0 --time=600  --threads=$i --percentile=95 --report-interval=60 oltp_read_write run &>> "$ofile"
done
```