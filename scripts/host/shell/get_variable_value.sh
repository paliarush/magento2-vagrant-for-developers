#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "$0")/../../.."; pwd)
variable_name=$1

# Enable trace printing and exit on the first error
set -ex

path_to_custom_value="${vagrant_dir}/local.config/${variable_name}.txt"
path_to_default_value="${vagrant_dir}/local.config/${variable_name}.txt.dist"

if [ -f ${path_to_custom_value} ]; then
    cat ${path_to_custom_value}
else
    cat ${path_to_default_value}
fi
