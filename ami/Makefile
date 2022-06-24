SCRIPTDIR := $(CURDIR)/scripts

.PHONY: check-env
check-env:

ifndef ENV
        $(error ENV is undefined)
endif

.PHONY:	rebuild
rebuild: check-env
	@$(SCRIPTDIR)/rebuild-image.sh
