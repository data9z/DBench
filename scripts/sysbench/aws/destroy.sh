#!/bin/bash
set -e

REGION=$1
TYPE=$2

DIR=aws/$TYPE/$REGION
CREDENTIALS="../../credentials.tfvars"
VARS="../$REGION.tfvars"

terraform -chdir=$DIR destroy -auto-approve -var-file=$CREDENTIALS -var-file=$VARS

rm -rf $DIR