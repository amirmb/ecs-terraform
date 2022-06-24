#!/bin/bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PACKERDIR=${SCRIPTDIR}/../packer

source ${SCRIPTDIR}/buildvars-${ENV}.sh

cd ${PACKERDIR}

make build

AMI=`cat ${PACKERDIR}/manifest.json | jq -r '.last_run_uuid as $last | .builds | map(select (.packer_run_uuid == $last)) | .[0] | .artifact_id' | sed 's/^.*://'`

cd ${SCRIPTDIR}/..

echo ${AMI} > ami.txt
