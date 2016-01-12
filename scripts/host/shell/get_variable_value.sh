#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "$0")/../../.."; pwd)
variable_name=$1

# Enable trace printing and exit on the first error
set -ex

. parse_yaml.sh

# read yaml file
eval $(parse_yaml "${vagrant_dir}/local.config/config.yaml.dist")
eval $(parse_yaml "${vagrant_dir}/local.config/config.yaml")

echo ${!variable_name}
