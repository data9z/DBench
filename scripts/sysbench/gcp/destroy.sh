#!/bin/bash
set -e

REGION=$1
TYPE=$2

DIR=gcp/$TYPE/$REGION
VARS="../$REGION.tfvars"

terraform -chdir=$DIR state list
terraform -chdir=$DIR destroy -auto-approve -var-file=$VARS

rm -rf $DIR