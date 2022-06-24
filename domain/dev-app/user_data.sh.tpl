#!/bin/bash -xe

CLUSTER_NAME=${name}-${env}-ecs-cluster
AUTH_TYPE=${auth_type}

. /etc/profile.d/proxy.sh

echo ECS_CLUSTER=$CLUSTER_NAME >> /etc/ecs/ecs.config
echo ECS_ENGINE_AUTH_TYPE=$AUTH_TYPE >> /etc/ecs/ecs.config
echo ECS_ENGINE_AUTH_DATA=$(/usr/local/bin/aws ssm get-parameter --region ap-southeast-2 --name ${aws_ssm_parameter.auth_data.id} --with-decryption | jq -r '.Parameter.Value') >> /etc/ecs/ecs.config
sudo service docker restart
echo ECS_ENGINE_AUTH_DATA=$(/usr/local/bin/aws ssm get-parameter --region ap-southeast-2 --name ${aws_ssm_parameter.auth_data.id} --with-decryption | jq -r '.Parameter.Value') >> /etc/ecs/config.json
