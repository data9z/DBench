#!/bin/bash
set -e

CLOUD=$1
REGION=$2

TABLE_SIZE=10000000

ACTION=$3

function run()
{
    THREADS=$1
    
    CMD="sysbench --db-driver=pgsql --pgsql-host=$DB_URL --pgsql-port=$DB_PORT --pgsql-user=$DB_USER --pgsql-password=$DB_PWD --pgsql-db=sbtest --table_size=$TABLE_SIZE --tables=10 --events=0 --time=360 --threads=$THREADS  --percentile=99  --report-interval=10 oltp_read_write run"
    echo "$CMD"
    ssh -i ssh.pem -o StrictHostKeyChecking=no $USER@$HOST $CMD
}

if [ "destroy" == $ACTION ] 
then
    $CLOUD/destroy.sh $REGION postgresql
    exit 0
elif [ "run" == $ACTION ] && [ -n "$4" ]
then    
    THREADS=$4

    source $CLOUD/init.sh $REGION postgresql $TABLE_SIZE

    echo "****************************** $THREADS threads ******************************"
    run $THREADS

    exit 0
elif [ "test" == $ACTION ] && [ -n "$4" ]
then    
    THREADS=$4

    source $CLOUD/init.sh $REGION postgresql $TABLE_SIZE test

    echo "****************************** $THREADS threads ******************************"
    run $THREADS

    exit 0    
else [ "run" == $ACTION ]
    
    source $CLOUD/init.sh $REGION postgresql $TABLE_SIZE

    echo "****************************** 16 threads ******************************"
    sleep 30s; run 16
    echo "****************************** 32 threads ******************************"
    sleep 30s; run 32
    echo "****************************** 64 threads ******************************"
    sleep 30s; run 64
    echo "****************************** 128 threads ******************************"
    sleep 30s; run 128
    echo "****************************** 256 threads ******************************"
    sleep 30s; run 256
    echo "****************************** 512 threads ******************************"
    sleep 30s; run 512

    exit 0
fi