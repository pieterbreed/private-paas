#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export DIST_FOLDER=~/Downloads
export DATOMIC_VERSION=0.9.5407 # TODO: This can be auto-discovered
export AWS_DEFAULT_REGION=us-east-1
export TF_VAR_region=${AWS_DEFAULT_REGION}
export TERRAFORM_PATH=$DIR/terraform

