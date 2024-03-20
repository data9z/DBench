#!/bin/bash
set -e

REGION=$1
TYPE=$2
TABLE_SIZE=$3

DIR=huaweicloud/$TYPE/$REGION

mkdir -p $DIR

echo "Get export IP"
EXT_IP="$(curl -s ifconfig.me)/32"
echo "Export IP ：$EXT_IP"

cp huaweicloud/$TYPE/main.tf $DIR/main.tf

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
DB_URL="$(terraform -chdir=$DIR output -raw url)"
DB_PORT="$(terraform -chdir=$DIR output -raw db_port)"
DB_USER="$(terraform -chdir=$DIR output -raw db_user)"
DB_PWD="$(terraform -chdir=$DIR output -raw db_pwd)"
CONTAINER="$(terraform -chdir=$DIR output -raw container)"

if ! $CONTAINER; then
    echo "wait os start..."
    sleep 10s
    CMD="if which sysbench > /dev/null 2>&1 ; then echo 'sysbench exists'; else curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash && sudo yum -y install sysbench; fi"
    echo "$CMD"
    ssh -i ssh.pem -o StrictHostKeyChecking=no $USER@$HOST $CMD
fi

CMD="sysbench --db-driver=mysql --mysql-host=$DB_URL --mysql-port=$DB_PORT --mysql-user=$DB_USER --mysql-password=$DB_PWD --mysql-db=sbtest --table_size=$TABLE_SIZE --tables=10 --events=0 --threads=20 oltp_read_write prepare"

if [ "postgresql" == $TYPE ] 
then
    LOGIN="if which psql > /dev/null 2>&1 ; then echo 'psql exists'; else yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm && yum install -y postgresql12; fi && export PGPASSWORD=$DB_PWD && psql -h $DB_URL -p $DB_PORT -U $DB_USER -d sbtest -c 'select now()'"
    echo "$LOGIN"
    ssh -i ssh.pem -o StrictHostKeyChecking=no $USER@$HOST $LOGIN
    
    CMD="sysbench --db-driver=pgsql --pgsql-host=$DB_URL --pgsql-port=$DB_PORT --pgsql-user=$DB_USER --pgsql-password=$DB_PWD --pgsql-db=sbtest --table_size=$TABLE_SIZE --tables=10 --events=0 --threads=20 --percentile=99 --report-interval=10 oltp_read_write prepare"
fi

if [ "test" == "$4" ] 
then
    echo "test run."
else
    echo "$CMD"
    ssh -i ssh.pem -o StrictHostKeyChecking=no $USER@$HOST $CMD
fi