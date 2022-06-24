#!/bin/bash

echo "===================================================================================="
echo "deploy-base"
echo "===================================================================================="

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TERRADIR=${SCRIPTDIR}/../domain/${ENV}-base

cd ${TERRADIR}

terraform init && terraform apply -auto-approve
