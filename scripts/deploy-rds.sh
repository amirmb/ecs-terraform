#!/bin/bash

echo "===================================================================================="
echo "deploy-rds"
echo "===================================================================================="

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TERRADIR=${SCRIPTDIR}/../domain/${ENV}-rds

cd ${TERRADIR}

terraform init && terraform apply -auto-approve
