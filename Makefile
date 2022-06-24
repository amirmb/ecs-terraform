# Don't echo target content
.SILENT:

# Export variables into child processes
.EXPORT_ALL_VARIABLES:

# Github tags for non-master builds
ifneq ($(BRANCH_NAME),)
ifneq ($(BRANCH_NAME),master)
	GITHUB_TAG_SUFFIX := $(shell date "+%Y%m%d")
endif
endif

# Required for Build and Deploy
BUILD_NUMBER ?= 0
GITHUB_TAG ?= v$(BUILD_NUMBER)$(GITHUB_TAG_SUFFIX)

# Compose magic to work around networking issues
UNAME := $()
ifeq ($(shell uname), Darwin)
	COMPOSE_COMMAND := docker-compose -f docker-compose.yml
else
	COMPOSE_COMMAND := docker-compose
endif

# Compose Commands
COMPOSE_RUN_TERRAFROM= $(COMPOSE_COMMAND) run --rm terraform
COMPOSE_RUN_PACKER = $(COMPOSE_COMMAND) run --rm packer

SCRIPTDIR := $(CURDIR)/scripts

#-------------------------------------------------------------------------------------------
.PHONY: check-env
check-env:

ifndef ENV
	$(error ENV is undefined)
endif
#-------------------------------------------------------------------------------------------
.PHONY: plan-base
plan-base:	check-env

	@$(SCRIPTDIR)/plan-base.sh
#-------------------------------------------------------------------------------------------
.PHONY: plan-rds
plan-rds:	check-env

	@$(SCRIPTDIR)/plan-rds.sh
#-------------------------------------------------------------------------------------------
.PHONY: plan-app
plan-mongo:	check-env

	@$(SCRIPTDIR)/plan-app.sh
#-------------------------------------------------------------------------------------------
deploy-base:	check-env

	@$(SCRIPTDIR)/deploy-base.sh
#-------------------------------------------------------------------------------------------
.PHONY: deploy-rds
deploy-rds:	check-env

	@$(SCRIPTDIR)/deploy-rds.sh
#-------------------------------------------------------------------------------------------
.PHONY: deploy-app
deploy-mongo:	check-env

	@$(SCRIPTDIR)/deploy-app.sh

clean: .env
	# clean Workspace
	$(COMPOSE_RUN_PYTHON) make _clean
	# clean Docker
	$(COMPOSE_COMMAND) down --remove-orphans --volumes
.PHONY: clean

print_tag:
	@echo $(GITHUB_TAG)
.PHONY: print_tag

prepare: .env
	$(COMPOSE_COMMAND) pull
.PHONY: prepare

_clean:
	rm -rf output
