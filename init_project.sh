#!/usr/bin/env bash

vagrant_dir=$PWD
magento_ce_dir="${vagrant_dir}/magento2ce"
magento_ee_dir="${magento_ce_dir}/magento2ee"

# Enable trace printing and exit on the first error
set -ex

bash "${vagrant_dir}/scripts/host/shell/check_requirements.sh"

force_project_cleaning=0
while getopts 'f' flag; do
  case "${flag}" in
    f) force_project_cleaning=1 ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

# Clean up the project before initialization if "-f" option was specified
if [ ${force_project_cleaning} -eq 1 ]; then
    vagrant destroy -f
    rm -rf ${magento_ce_dir} ${vagrant_dir}/.idea ${vagrant_dir}/.vagrant
fi

if [ ! -d ${magento_ce_dir} ]; then
    # Check out CE repository
    repository_url_ce=$(bash "${vagrant_dir}/scripts/host/shell/get_variable_value.sh" "repository_url_ce")
    git clone ${repository_url_ce} ${magento_ce_dir}
    # Check out EE repository
    # By default EE repository is not specified and EE project is not checked out
    repository_url_ee=$(bash "${vagrant_dir}/scripts/host/shell/get_variable_value.sh" "repository_url_ee")
    if [ -n "${repository_url_ee}" ]; then
        git clone ${repository_url_ee} ${magento_ee_dir}
    fi
fi


var_generation_dir="${magento_ce_dir}/var/generation"
if [ ! -d ${var_generation_dir} ] ; then
    host_os=$(bash "${vagrant_dir}/scripts/host/shell/get_host_os.sh")
    if [[ ${host_os} == "Windows" || $(bash "${vagrant_dir}/scripts/host/shell/get_variable_value.sh" "guest_use_nfs") == 0 ]]; then
        mkdir ${var_generation_dir}
    fi
fi

# Update Magento dependencies via Composer
cd ${magento_ce_dir}
bash "${vagrant_dir}/scripts/host/shell/composer.sh" install

# Install necessary vagrant plugins if not installed
if ! vagrant plugin list | grep -q 'hostmanager' ; then
    vagrant plugin install vagrant-hostmanager
fi
if ! vagrant plugin list | grep -q 'vbguest' ; then
    vagrant plugin install vagrant-vbguest
fi

# Create vagrant project
cd ${vagrant_dir}
vagrant up

bash "${vagrant_dir}/scripts/host/shell/configure_php_storm.sh"
