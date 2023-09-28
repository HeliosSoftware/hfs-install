#
#
#
.ONESHELL:
.SHELL := /bin/bash
.PHONY: common cassandra
.EXPORT_ALL_VARIABLES:
CURRENT_FOLDER=$(shell basename "$$(pwd)")
ENVIRONMENT ?= dev
EXTRA ?= "-e 'makefile=true' -v"
PASSWORD_FILE ?= ~/.vault_pass.txt
# Bug running on OSX
OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
ANSIBLE_USER=ubuntu
ifeq ($(ENVIRONMENT),dev)
DOMAIN=dev.vdp.vero.host
else
DOMAIN=prd.vdp.vero.host
endif
VAULT_ADDR=https://vault.${DOMAIN}
INVENTORY=inventory/cassandra_aws_ec2.yaml

# Default to use pipenv unless disabled
PIPENV=true
ifeq ($(PIPENV),true)
PIPENVCMD=pipenv run
else
PIPENVCMD=
endif

check-env:
        @if [ ! "$(CLUSTER_NAME)" ]; then echo "$(BOLD)$(RED)CLUSTER_NAME is not set$(RESET)"; exit 1;fi

test:
        @echo $(DOMAIN)
        @echo $(VAULT_ADDR)

check: ## run pre-commit tests
        @${PIPENVCMD} pre-commit run --all-files

help:
        @grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

common: ## Deploy consul for Patroni
        @${PIPENVCMD} ansible-playbook -i ${INVENTORY} deploy-common.yml --diff ${EXTRA} -u ${ANSIBLE_USER} \
                -e vault_addr=$(VAULT_ADDR) \
                -e target=cassandra-${CLUSTER_NAME} --vault-password-file ${PASSWORD_FILE}

cassandra: check-env ## Deploy Cassandra
        # @${PIPENVCMD} ansible-galaxy install -r requirements.yml
        @${PIPENVCMD} ansible-playbook -i ${INVENTORY} deploy-cassandra.yml --diff ${EXTRA} \
                -u ${ANSIBLE_USER} -e cluster_name=$(ENVIRONMENT)_$(CLUSTER_NAME) \
                -e env=${ENVIRONMENT} \
                -e vault_addr=$(VAULT_ADDR) \
                --vault-password-file ${PASSWORD_FILE}

cassandra-init: check-env ## Deploy Cassandra
        # @${PIPENVCMD} ansible-galaxy install -r requirements.yml
        @${PIPENVCMD} ansible-playbook -i ${INVENTORY} cassandra-init.yml --diff ${EXTRA} \
                -u ${ANSIBLE_USER} -e cluster_name=$(ENVIRONMENT)_$(CLUSTER_NAME) \
                -e env=${ENVIRONMENT} \
                -e vault_addr=$(VAULT_ADDR) \
                --vault-password-file ${PASSWORD_FILE}

restart-axon-agent:
        @ansible -i ${INVENTORY} all --become -a 'systemctl restart axon-agent' -u ${ANSIBLE_USER}

reset-axon-agent:
        @ansible -i ${INVENTORY} all --become -a 'systemctl stop axon-agent' -u ${ANSIBLE_USER}
        @ansible -i ${INVENTORY} all --become -a 'rm -f /var/lib/axonops/hostId /var/lib/axonops/*.db' -u ${ANSIBLE_USER}
        @ansible -i ${INVENTORY} all --become -a 'systemctl start axon-agent' -u ${ANSIBLE_USER}

start-cassandra:
        @${PIPENVCMD} ansible-playbook -i ${INVENTORY} start-cassandra.yml --diff ${EXTRA} \
                -u ${ANSIBLE_USER} -e cluster_name=$(ENVIRONMENT)_$(CLUSTER_NAME) \
                -e env=${ENVIRONMENT} \
                --vault-password-file ${PASSWORD_FILE}