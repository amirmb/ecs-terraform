GIT_BRANCH := $(shell if [ "x${GIT_BRANCH}" == "x" ]; then git rev-parse --abbrev-ref HEAD ; else echo ${GIT_BRANCH}; fi )
GIT_COMMIT := $(shell if [ "x${GIT_COMMIT}" == "x" ]; then git rev-parse HEAD ; else echo ${GIT_COMMIT}; fi )

.PHONY:	check-vars
check-vars:

ifndef AWS_ACCOUNT_ID
	$(error AWS_ACCOUNT_ID is undefined)
endif

ifndef SUBNET_ID
	$(error SUBNET_ID is undefined)
endif

ifndef VPC_ID
	$(error VPC_ID is undefined)
endif

ifndef PROVISIONING_PROFILE
        $(error PROVISIONING_PROFILE is undefined)
endif

ifndef ENVIRONMENT
        $(error ENVIRONMENT is undefined)
endif

.PHONY: validate
validate: check-vars
	packer validate -var subnet_id=$(SUBNET_ID) -var vpc_id=$(VPC_ID) -var aws_account_id=$(AWS_ACCOUNT_ID) -var git_branch=$(GIT_BRANCH) -var git_commit=$(GIT_COMMIT) -var provisioning_profile=$(PROVISIONING_PROFILE) -var environment=$(ENVIRONMENT) packer.json

.PHONY: build
build:  check-vars
	AWS_MAX_ATTEMPTS=150 AWS_POLL_DELAY_SECONDS=5 packer build -var subnet_id=$(SUBNET_ID) -var vpc_id=$(VPC_ID) -var aws_account_id=$(AWS_ACCOUNT_ID) -var git_branch=$(GIT_BRANCH) -var git_commit=$(GIT_COMMIT) -var provisioning_profile=$(PROVISIONING_PROFILE) -var environment=$(ENVIRONMENT) packer.json

