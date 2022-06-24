#!/bin/bash

echo "===================================================================================="
echo "plan-rds"
echo "===================================================================================="

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TERRADIR=${SCRIPTDIR}/../domain/${ENV}-rds

cd ${TERRADIR}

terraform init && terraform plan
