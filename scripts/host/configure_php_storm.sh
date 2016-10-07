#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"

status "Configuring PhpStorm"
incrementNestingLevel

cd "${vagrant_dir}"
ssh_port="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "guest_forwarded_ssh_port")"
magento_host_name="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "magento_host_name")"

cp -R "${vagrant_dir}/scripts/host/php-storm-configs/." "${vagrant_dir}/.idea/"

enabled_virtual_host_config="/etc/apache2/sites-available/magento2.conf"

host_os="$(bash "${vagrant_dir}/scripts/host/get_host_os.sh")"
if [[ ${host_os} == "Windows" ]] || [[ $(bash "${vagrant_dir}/scripts/get_config_value.sh" "guest_use_nfs") == 0 ]]; then
    sed -i.back "s|<magento_guest_path>|/var/www/magento2ce|g" "${vagrant_dir}/.idea/deployment.xml"
    sed -i.back 's|<auto_upload_attributes>| autoUpload="Always" autoUploadExternalChanges="true"|g' "${vagrant_dir}/.idea/deployment.xml"
    sed -i.back 's|<auto_upload_option>|<option name="myAutoUpload" value="ALWAYS" />|g' "${vagrant_dir}/.idea/deployment.xml"
else
    sed -i.back "s|<magento_guest_path>|\$PROJECT_DIR\$/magento2ce|g" "${vagrant_dir}/.idea/deployment.xml"
    sed -i.back 's|<auto_upload_attributes>||g' "${vagrant_dir}/.idea/deployment.xml"
    sed -i.back 's|<auto_upload_option>||g' "${vagrant_dir}/.idea/deployment.xml"
fi

sed -i.back "s|<host_name>|${magento_host_name}|g" "${vagrant_dir}/.idea/webServers.xml"
sed -i.back "s|<ssh_port>|${ssh_port}|g" "${vagrant_dir}/.idea/webServers.xml"
sed -i.back "s|<host_name>|${magento_host_name}|g" "${vagrant_dir}/.idea/php.xml"
sed -i.back "s|<ssh_port>|${ssh_port}|g" "${vagrant_dir}/.idea/php.xml"
sed -i.back "s|<host_name>|${magento_host_name}|g" "${vagrant_dir}/.idea/deployment.xml"
sed -i.back "s|<host_name>|${magento_host_name}|g" "${vagrant_dir}/.idea/deployment.xml"
sed -i.back "s|<host_name>|${magento_host_name}|g" "${vagrant_dir}/.idea/.name"
sed -i.back "s|<host_name>|${magento_host_name}|g" "${vagrant_dir}/.idea/modules.xml"
sed -i.back "s|<host_name>|${magento_host_name}|g" "${vagrant_dir}/.idea/remote-mappings.xml"
rm -rf "${vagrant_dir}/.idea/*.back"
rm -f "${vagrant_dir}/.idea/.name.back"

mv "${vagrant_dir}/.idea/host_name.iml" "${vagrant_dir}/.idea/${magento_host_name}.iml"

repository_url_ee="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "repository_url_ee")"
if [[ -z ${repository_url_ee} ]]; then
    mv "${vagrant_dir}/.idea/vcs.ce.xml" "${vagrant_dir}/.idea/vcs.xml"
    rm "${vagrant_dir}/.idea/vcs.ee.xml"
else
    mv "${vagrant_dir}/.idea/vcs.ee.xml" "${vagrant_dir}/.idea/vcs.xml"
    rm "${vagrant_dir}/.idea/vcs.ce.xml"
fi

decrementNestingLevel
