#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"

magento_app_code_dir="${vagrant_dir}/magento/app/code/Magento"

cd "${magento_app_code_dir}"

status "Deleting TestModule directories"
ls | grep "TestModule" | xargs rm -rf

cd "${vagrant_dir}"

# TODO: parameterize container

magento2_pod_id="$(kubectl get pods | grep -ohE 'magento2-[a-z0-9]{9}-[a-z0-9]{5}')"
kubectl exec "${magento2_pod_id}" --container magento2 bash "/var/www/html/scripts/guest/m-reinstall" 2> >(logError)
# Explicit exit is necessary to bypass incorrect output from vagrant in case of errors
exit 0
