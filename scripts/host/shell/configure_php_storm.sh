#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "$0")/../../.."; pwd)
composer_auth_json="${vagrant_dir}/local.config/composer/auth.json"

# Enable trace printing and exit on the first error
set -ex

cd ${vagrant_dir}
ssh_port=$(bash "${vagrant_dir}/scripts/host/shell/get_variable_value.sh" "guest_forwarded_ssh_port")
magento_host_name=$(bash "${vagrant_dir}/scripts/host/shell/get_variable_value.sh" "magento_host_name")

cp -R "${vagrant_dir}/scripts/host/php-storm-configs/." "${vagrant_dir}/.idea/"

enabled_virtual_host_config="/etc/apache2/sites-available/magento2.conf"

host_os=$(bash "${vagrant_dir}/scripts/host/shell/get_host_os.sh")
if [[ ${host_os} == "Windows" || $(bash "${vagrant_dir}/scripts/host/shell/get_variable_value.sh" "guest_use_nfs") == 0 ]]; then
    sed -i.back "s|<magento_guest_path>|/var/www/magento2ce|g" "${vagrant_dir}/.idea/deployment.xml"
    sed -i.back 's|<auto_upload_attributes>| autoUpload="Always" autoUploadExternalChanges="true"|g' "${vagrant_dir}/.idea/deployment.xml"
    sed -i.back 's|<auto_upload_option>|<option name="myAutoUpload" value="ALWAYS" />|g' "${vagrant_dir}/.idea/deployment.xml"
else
    sed -i.back "s|<magento_guest_path>|\$PROJECT_DIR\$/magento2ce|g" "${vagrant_dir}/.idea/deployment.xml"
    sed -i.back 's|<auto_upload_attributes>||g' "${vagrant_dir}/.idea/deployment.xml"
    sed -i.back 's|<auto_upload_option>||g' "${vagrant_dir}/.idea/deployment.xml"
fi

find ${vagrant_dir}/.idea -type f -print0 | xargs -0 sed -i.back "s|<host_name>|${magento_host_name}|g"
find ${vagrant_dir}/.idea -type f -print0 | xargs -0 sed -i.back "s|<ssh_port>|${ssh_port}|g"
mv "${vagrant_dir}/.idea/host_name.iml" "${vagrant_dir}/.idea/${magento_host_name}.iml"
rm -rf ${vagrant_dir}/.idea/*.back

repository_url_ee=$(bash "${vagrant_dir}/scripts/host/shell/get_variable_value.sh" "repository_url_ee")
if [ -z ${repository_url_ee} ]; then
    mv "${vagrant_dir}/.idea/vcs.ce.xml" "${vagrant_dir}/.idea/vcs.xml"
    rm "${vagrant_dir}/.idea/vcs.ee.xml"
else
    mv "${vagrant_dir}/.idea/vcs.ee.xml" "${vagrant_dir}/.idea/vcs.xml"
    rm "${vagrant_dir}/.idea/vcs.ce.xml"
fi

# Generate PHP Storm settings for import
cp -R "${vagrant_dir}/scripts/host/phpstorm-settings" "${vagrant_dir}/local.config"

find ${vagrant_dir}/local.config/phpstorm-settings -type f -print0 | xargs -0 sed -i.back "s|<host_name>|${magento_host_name}|g"
find ${vagrant_dir}/local.config/phpstorm-settings -type f -print0 | xargs -0 sed -i.back "s|<ssh_port>|${ssh_port}|g"

rm -rf ${vagrant_dir}/local.config/phpstorm-settings/*.back
cd ${vagrant_dir}/local.config/phpstorm-settings
jar cfM ${vagrant_dir}/local.config/phpstorm_settings.jar *
rm -rf ${vagrant_dir}/local.config/phpstorm-settings
