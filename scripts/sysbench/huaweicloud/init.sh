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

if [ "test" == "$4" ] 
then
    echo "test run."
    PORT=9022
    USER="root"
else

    if ! $CONTAINER; then
        echo "wait os start..."
        sleep 10s
        PORT=22
        CMD="yum install -y docker ; systemctl restart docker ; docker stop sysbench ; docker rm sysbench ; docker run -id --name=sysbench -p 9022:22 registry.cn-hangzhou.aliyuncs.com/ninedata_public/sysbench:latest /bin/bash -c '/usr/sbin/sshd && sleep infinity'"
        echo "$CMD"
        ssh -i ssh.pem -p $PORT -o StrictHostKeyChecking=no $USER@$HOST $CMD
        PORT=9022
        USER="root"
    fi

    CMD="sysbench --db-driver=mysql --mysql-host=$DB_URL --mysql-port=$DB_PORT --mysql-user=$DB_USER --mysql-password=$DB_PWD --mysql-db=sbtest --table_size=$TABLE_SIZE --tables=10 --events=0 --threads=20 oltp_read_write prepare"

    if [ "postgresql" == $TYPE ] 
    then
        LOGIN="export PGPASSWORD=$DB_PWD && psql -h $DB_URL -p $DB_PORT -U $DB_USER -d sbtest -c 'select now()'"
        echo "$LOGIN"
        ssh -i ssh.pem -p $PORT -o StrictHostKeyChecking=no $USER@$HOST $LOGIN
        
        CMD="sysbench --db-driver=pgsql --pgsql-host=$DB_URL --pgsql-port=$DB_PORT --pgsql-user=$DB_USER --pgsql-password=$DB_PWD --pgsql-db=sbtest --table_size=$TABLE_SIZE --tables=10 --events=0 --threads=20 --percentile=95 --report-interval=10 oltp_read_write prepare"
    fi

    echo "$CMD"
    ssh -i ssh.pem -p $PORT -o StrictHostKeyChecking=no $USER@$HOST $CMD
fi