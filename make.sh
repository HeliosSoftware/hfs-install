#!/bin/bash

BASEDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [ "$1" = "full-clean" ]
then
	echo "Removing all .terraform* files and directories from all projects"
	cd "$BASEDIR"
	rm -rf */.terraform*
	exit $?
fi


if [ "$ENV" == "" ]
then
	ENV=dev
fi
ENVIRONMENT=$ENV
export ENV
export ENVIRONMENT
export EXTRA_OPTS
export CUSTOMER=gbg
export AWS_REGION=${REGION}
export DC

PRODUCT=$1
OPERATION=$2
export PRODUCT
shift

[ -z ${BACKENDCONFIG} ] && export BACKENDCONFIG="${ENVIRONMENT}-${REGION}-${DC}-${PRODUCT}"
[ -z ${S3TFSTATEBUCKET} ] && export S3TFSTATEBUCKET=axonops-repository-${CUSTOMER}-tf-state
echo using ${S3TFSTATEBUCKET} for terraform state bucket
echo using ${BACKENDCONFIG} for terraform state file


if [ "$PRODUCT" = "" ] || [ "$OPERATION" = "" ]
then
	echo "Usage: $0 product operation"
	echo " e.g. $0 management plan"
	echo "Set the ENV environment variable to override the default params file name"+
	exit 1
fi

case "$OPERATION" in
apply|destroy|force-unlock)
	DANGEROUS=1
;;
plan*|prep|force-init|importcmd|console)
	DANGEROUS=0
;;
*)
	echo "ERROR: Unknown operation $OPERATION"
	exit 1
esac

PRODUCT_DIR="$BASEDIR/$PRODUCT"
if ! cd "$PRODUCT_DIR"
then
	echo "ERROR: Directory not found for product $PRODUCT"
	exit 1
fi

#if [ $DANGEROUS -eq 1 ] && [ "$ENV" == "prod" ]
#then
#		while [ "$ENTERED" != "production" ]
#		do
#				read -p "You are building into environment '$ENV'. Please type \"production\" to continue: " ENTERED
#		done
#fi

if [ "$ENV" != "" ]
then
  PARAMS_FILE="$PRODUCT_DIR/params/params.$ENV.tfvars"
else
  PARAMS_FILE="$PRODUCT_DIR/params/params.tfvars"
fi

if [ -r "$PARAMS_FILE" ]
then
  VARS_ARG="-var-file='$PARAMS_FILE'"
  export VARS_ARG
fi

SUCCESS=0
if make -f "$BASEDIR/Makefile.mk" $@
then
	SUCCESS=1
fi
