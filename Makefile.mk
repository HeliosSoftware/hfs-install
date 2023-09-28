#
#
#
.EXPORT_ALL_VARIABLES:
.ONESHELL:
.SHELL := /bin/bash
.PHONY: apply destroy plan prep force-unlock force-init console
CURRENT_FOLDER=$(shell basename "$$(pwd)")
RED='\033[0;31m'
GREEN='\032[0;31m'
YELLOW='\033[0;31m'
RESET='\033[0m'
BOLD='\033[31;1;4m'

# Region for backend (state) storage
REGION ?= us-east-1

FORCE=0
GCR_AUTH_TOKEN ?= 0

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check-env:
	@if [ ! "$(AWS_ACCESS_KEY_ID)" ]; then echo "$(BOLD)$(RED)AWS_ACCESS_KEY_ID is not set$(RESET)"; exit 1;fi
	@if [ ! "$(AWS_SECRET_ACCESS_KEY)" ]; then echo "$(BOLD)$(RED)AWS_SECRET_ACCESS_KEY is not set$(RESET)"; exit 1;fi
	@if [ ! "$(CUSTOMER)" ]; then echo "$(BOLD)$(RED)CUSTOMER is not set$(RESET)"; exit 1;fi

fmt:
	@terraform fmt -recursive

force-init:
	@if [ $(FORCE) -gt 0 ]; then rm -rf .terraform; fi

prep: check-env force-init
	@if [ ! -d .terraform -o ${FORCE} -gt 0 ]; then \
	terraform init
	fi

plan: prep ## Show what terraform thinks it will do
	@terraform plan \
		-detailed-exitcode \
		-out=plan.out \
		-lock=true \
		-input=false \
		-refresh=true \
		${VARS_ARG} \
		${EXTRA_OPTS}; \
		EXIT_CODE=$$?; \
		echo "Plan exited with status $$EXIT_CODE"; \
		echo $$EXIT_CODE

plan-destroy: prep ## Show what terraform thinks it will do
	@terraform plan \
		-destroy \
		-detailed-exitcode \
		-out=plan.out \
		-lock=true \
		-input=false \
		-refresh=true \
		${VARS_ARG} \
		${EXTRA_OPTS}; \
		EXIT_CODE=$$?; \
		echo "Plan exited with status $$EXIT_CODE"; \
		echo $$EXIT_CODE

apply: prep ## Have terraform do the things. This will cost money.
	@terraform apply \
		-lock=true \
		-input=false \
		-auto-approve \
		-refresh=true \
		${VARS_ARG} \
		${EXTRA_OPTS}

destroy: prep ## Destroy the things
	@terraform destroy \
		-lock=true \
		-input=false \
		-auto-approve \
		-refresh=true \
		${VARS_ARG} \
		${EXTRA_OPTS}

console: prep ## Connect to terraform console
	@terraform console \
		${VARS_ARG} \
		${EXTRA_OPTS}

importcmd:
	@echo "Import command for $(PRODUCT):"
	@echo terraform import \
		-lock=true \
		-input=false \
		${VARS_ARG} \
		${EXTRA_OPTS}
	@echo

force-unlock: prep ## Force unlock from env variable TF_FORCE_UNLOCK=id
	@terraform force-unlock $(TF_FORCE_UNLOCK)
