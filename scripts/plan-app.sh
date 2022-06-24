#!/bin/bash

echo "===================================================================================="
echo "plan-app"
echo "===================================================================================="

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TERRADIR=${SCRIPTDIR}/../domain/${ENV}-app

cd ${TERRADIR}

terraform init && terraform plan
