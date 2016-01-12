#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "$0")/../.."; pwd)
composer_auth_json="${vagrant_dir}/local.config/composer/auth.json"

# Enable trace printing and exit on the first error
set -ex

cd ${vagrant_dir}
ssh_port="$(vagrant port --guest 22)"
magento_host_name=$(sh "${vagrant_dir}/scripts/host/get_variable_value.sh" "magento_host_name")

cp -R "${vagrant_dir}/scripts/host/php-storm-configs" "${vagrant_dir}/.idea"

enabled_virtual_host_config="/etc/apache2/sites-available/magento2.conf"
sed -i '' "s|<host_name>|${magento_host_name}|g" "${vagrant_dir}/.idea/webServers.xml"
sed -i '' "s|<ssh_port>|${ssh_port}|g" "${vagrant_dir}/.idea/webServers.xml"
sed -i '' "s|<host_name>|${magento_host_name}|g" "${vagrant_dir}/.idea/php.xml"
sed -i '' "s|<ssh_port>|${ssh_port}|g" "${vagrant_dir}/.idea/php.xml"
sed -i '' "s|<host_name>|${magento_host_name}|g" "${vagrant_dir}/.idea/deployment.xml"
sed -i '' "s|<host_name>|${magento_host_name}|g" "${vagrant_dir}/.idea/.name"
sed -i '' "s|<host_name>|${magento_host_name}|g" "${vagrant_dir}/.idea/modules.xml"

mv "${vagrant_dir}/.idea/<host_name>.iml" "${vagrant_dir}/.idea/${magento_host_name}.iml"

ee_repository_url=$(sh "${vagrant_dir}/scripts/host/get_variable_value.sh" "repository_url_ee")
if [ -z ${ee_repository_url} ]; then
    mv "${vagrant_dir}/.idea/vcs.ce.xml" "${vagrant_dir}/.idea/vcs.xml"
    rm "${vagrant_dir}/.idea/vcs.ee.xml"
else
    mv "${vagrant_dir}/.idea/vcs.ee.xml" "${vagrant_dir}/.idea/vcs.xml"
    rm "${vagrant_dir}/.idea/vcs.ce.xml"
fi
