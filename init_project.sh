#!/usr/bin/env bash

set -e

vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"
resetNestingLevel

config_path="${vagrant_dir}/etc/config.yaml"
if [[ ! -f "${config_path}" ]]; then
    status "Initializing etc/config.yaml using defaults from etc/config.yaml.dist"
    cp "${config_path}.dist" "${config_path}"
fi

magento_ce_dir="${vagrant_dir}/magento2ce"
magento_ce_sample_data_dir="${magento_ce_dir}/magento2ce-sample-data"
magento_ee_dir="${magento_ce_dir}/magento2ee"
magento_ee_sample_data_dir="${magento_ce_dir}/magento2ee-sample-data"
host_os="$(bash "${vagrant_dir}/scripts/host/get_host_os.sh")"
use_nfs="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "guest_use_nfs")"
repository_url_ce="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "repository_url_ce")"
repository_url_ee="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "repository_url_ee")"

bash "${vagrant_dir}/scripts/host/check_requirements.sh"

status "Installing missing vagrant plugins"
vagrant_plugin_list="$(vagrant plugin list)"
if ! echo ${vagrant_plugin_list} | grep -q 'vagrant-hostmanager' ; then
    vagrant plugin install vagrant-hostmanager
fi
if ! echo ${vagrant_plugin_list} | grep -q 'vagrant-vbguest' ; then
    vagrant plugin install vagrant-vbguest
fi
if ! echo ${vagrant_plugin_list} | grep -q 'vagrant-host-shell' ; then
    vagrant plugin install vagrant-host-shell
fi

status "Generating random IP address, and host name to prevent collisions (if no custom values specified)"
random_ip="$(( ( RANDOM % 240 )  + 12 ))"
forwarded_ssh_port="$(( random_ip + 3000 ))"
sed -i.back "s|ip_address: \"192.168.10.2\"|ip_address: \"192.168.10.${random_ip}\"|g" "${config_path}"
sed -i.back "s|host_name: \"magento2.vagrant2\"|host_name: \"magento2.vagrant${random_ip}\"|g" "${config_path}"
sed -i.back "s|forwarded_ssh_port: 3000|forwarded_ssh_port: ${forwarded_ssh_port}|g" "${config_path}"
rm -f "${config_path}.back"

# Clean up the project before initialization if "-f" option was specified. Remove codebase if "-fc" is used.
force_project_cleaning=0
force_codebase_cleaning=0
force_phpstorm_config_cleaning=0
while getopts 'fcp' flag; do
  case "${flag}" in
    f) force_project_cleaning=1 ;;
    c) force_codebase_cleaning=1 ;;
    p) force_phpstorm_config_cleaning=1 ;;
    *) error "Unexpected option" && exit 1;;
  esac
done
if [[ ${force_project_cleaning} -eq 1 ]]; then
    status "Cleaning up the project before initialization since '-f' option was used"
    vagrant destroy -f 2> >(logError) > >(log)
    mv "${vagrant_dir}/etc/guest/.gitignore" "${vagrant_dir}/etc/.gitignore.back"
    rm -rf "${vagrant_dir}/.vagrant" "${vagrant_dir}/etc/guest"
    mkdir "${vagrant_dir}/etc/guest"
    mv "${vagrant_dir}/etc/.gitignore.back" "${vagrant_dir}/etc/guest/.gitignore"
    cd "${vagrant_dir}/log" && mv email/.gitignore email_gitignore.back && rm -rf email && mkdir email && mv email_gitignore.back email/.gitignore
    if [[ ${force_codebase_cleaning} -eq 1 ]]; then
        status "Removing current Magento codebase before initialization since '-c' option was used"
        rm -rf "${magento_ce_dir}"
    fi
fi

if [[ ! -d ${magento_ce_dir} ]]; then
    if [[ ${host_os} == "Windows" ]]; then
        status "Configuring git for Windows host"
        git config --global core.autocrlf false
        git config --global core.eol LF
        git config --global diff.renamelimit 5000
    fi
    status "Checking out CE repository"
    git clone ${repository_url_ce} "${magento_ce_dir}" 2> >(logError) > >(log)
    status "Checking out CE sample data repository"
    repository_url_ce_sample_data="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "repository_url_ce_sample_data")"
    git clone ${repository_url_ce_sample_data} "${magento_ce_sample_data_dir}" 2> >(logError) > >(log)
    # By default EE repository is not specified and EE project is not checked out
    if [[ -n "${repository_url_ee}" ]]; then
        status "Checking out EE repository"
        git clone ${repository_url_ee} "${magento_ee_dir}" 2> >(logError) > >(log)
    fi
    # By default EE sample data repository is not specified and EE project is not checked out
    repository_url_ee_sample_data="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "repository_url_ee_sample_data")"
    if [ -n "${repository_url_ee_sample_data}" ]; then
        status "Checking out EE sample data repository"
        git clone ${repository_url_ee_sample_data} "${magento_ee_sample_data_dir}" 2> >(logError) > >(log)
    fi
fi

status "Installing Magento dependencies via Composer"
cd "${magento_ce_dir}"
bash "${vagrant_dir}/scripts/host/composer.sh" install

status "Initializing vagrant box"
cd "${vagrant_dir}"

vagrant up 2> >(logError) | {
  while IFS= read -r line
  do
    filterVagrantOutput "${line}"
    lastline="${line}"
  done
  filterVagrantOutput "${lastline}"
}

if [[ ${force_project_cleaning} -eq 1 ]] && [[ ${force_phpstorm_config_cleaning} -eq 1 ]]; then
    status "Resetting PhpStorm configuration since '-p' option was used"
    rm -rf "${vagrant_dir}/.idea"
fi
if [[ ! -f "${vagrant_dir}/.idea/deployment.xml" ]]; then
    bash "${vagrant_dir}/scripts/host/configure_php_storm.sh"
fi

if [[ ${host_os} == "Windows" ]] || [[ ${use_nfs} == 0 ]]; then
    # Automatic switch to EE during project initialization cannot be supported on Windows
    status "Installing Magento CE"
    bash "${vagrant_dir}/scripts/host/m_reinstall.sh" 2> >(logError)
else
    if [[ -n "${repository_url_ee}" ]]; then
        bash "${vagrant_dir}/scripts/host/m_switch_to_ee.sh" -f 2> >(logError)
    else
        bash "${vagrant_dir}/scripts/host/m_switch_to_ce.sh" -f 2> >(logError)
    fi
fi

success "Project initialization succesfully completed"

info "$(bold)[Important]$(regular)
    Please use $(bold)${vagrant_dir}$(regular) directory as PhpStorm project root, NOT $(bold)${magento_ce_dir}$(regular)."

if [[ ${host_os} == "Windows" ]] || [[ ${use_nfs} == 0 ]]; then
    info "$(bold)[Optional]$(regular)
    To verify that deployment configuration for $(bold)${magento_ce_dir}$(regular) in PhpStorm is correct,
        use instructions provided here: $(bold)https://github.com/paliarush/magento2-vagrant-for-developers/blob/2.0/docs/phpstorm-configuration-windows-hosts.md$(regular).
    If not using PhpStorm, you can set up synchronization using rsync"
fi

info "See detailed log in '${vagrant_dir}/log/debug.log'"
