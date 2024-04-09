#!/bin/bash
set -e

REGION=$1
TYPE=$2
TABLE_SIZE=$3

DIR=alicloud/$TYPE/$REGION


mkdir -p $DIR

echo "Get export IP"
EXT_IP="$(curl -s ifconfig.me)/32"
echo "Export IP ：$EXT_IP"

cp alicloud/$TYPE/main.tf $DIR/main.tf

CREDENTIALS="../../credentials.tfvars"
VARS="../$REGION.tfvars"

terraform -chdir=$DIR init


if [ "test" == "$4" ] 
then
    echo "test run."
else
    terraform -chdir=$DIR apply -auto-approve -var-file=$CREDENTIALS -var-file=$VARS -var="ext_ip=$EXT_IP"
fi


HOST="$(terraform -chdir=$DIR output -raw host)"
USER="$(terraform -chdir=$DIR output -raw user)"
PORT=22
DB_URL="$(terraform -chdir=$DIR output -raw url)"
DB_PORT="$(terraform -chdir=$DIR output -raw db_port)"
DB_USER="$(terraform -chdir=$DIR output -raw db_user)"
DB_PWD="$(terraform -chdir=$DIR output -raw db_pwd)"
CONTAINER="$(terraform -chdir=$DIR output -raw container)"

CMD="sysbench --db-driver=mysql --mysql-host=$DB_URL --mysql-port=$DB_PORT --mysql-user=$DB_USER --mysql-password=$DB_PWD --mysql-db=sbtest --table_size=$TABLE_SIZE --tables=10 --events=0 --threads=20 oltp_read_write prepare"

if [ "postgresql" == $TYPE ] 
then
    CMD="sysbench --db-driver=pgsql --pgsql-host=$DB_URL --pgsql-port=$DB_PORT --pgsql-user=$DB_USER --pgsql-password=$DB_PWD --pgsql-db=sbtest --table_size=$TABLE_SIZE --tables=10 --events=0 --threads=20 --percentile=95 --report-interval=10 oltp_read_write prepare"
fi

if [ "test" == "$4" ] 
then
    echo "test run."
else
    echo "wait db start..."
    sleep 10s

    echo "$CMD"
    ssh -i ssh.pem -o StrictHostKeyChecking=no $USER@$HOST $CMD
fi
