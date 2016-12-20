#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"

status "Switching to Magento CE"
incrementNestingLevel

magento_ce_dir="${vagrant_dir}/magento2ce"
magento_ee_dir="${magento_ce_dir}/magento2ee"
host_os="$(bash "${vagrant_dir}/scripts/host/get_host_os.sh")"
php_executable="$(bash "${vagrant_dir}/scripts/host/get_path_to_php.sh")"
checkout_source_from="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "checkout_source_from")"

force_switch=0
upgrade_only=0
while getopts 'fu' flag; do
  case "${flag}" in
    f) force_switch=1 ;;
    u) upgrade_only=1 ;;
    *) error "Unexpected option" && decrementNestingLevel && exit 1;;
  esac
done

if [[ "${checkout_source_from}" == "git" ]]; then
    # Current installation is Git-based
    if [[ ! -f ${magento_ee_dir}/LICENSE_EE.txt ]]; then
        if [[ ${force_switch} -eq 0 ]]; then
            error "EE codebase is not available. Use 'm-switch-to-ce -f' to switch anyway."
            decrementNestingLevel
            exit 0
        fi
    else
        if [[ ! -f ${magento_ce_dir}/LICENSE_EE.txt ]] && [[ ${force_switch} -eq 0 ]]; then
            warning "Already switched to CE. Use 'm-switch-to-ce -f' to switch anyway."
            decrementNestingLevel
            exit 0
        fi

        status "Unlinking EE repository"
        ${php_executable} -f ${magento_ee_dir}/dev/tools/build-ee.php -- --command=unlink --ee-source="${magento_ee_dir}" --ce-source="${magento_ce_dir}" --exclude=true 2> >(logError) > >(log)

       # TODO: Remove after some time. For now this is left for backward compatibility
        cd ${magento_ce_dir}
        git checkout composer.json
        git checkout composer.lock

        if [[ ${host_os} == "Windows" ]] || [[ $(bash "${vagrant_dir}/scripts/get_config_value.sh" "guest_use_nfs") == 0 ]]; then
            # Prevent issues on Windows with incorrect symlinks to files
            if [[ -f ${magento_ce_dir}/app/etc/aliases_to_classes_map.json ]]; then
                rm ${magento_ce_dir}/app/etc/aliases_to_classes_map.json
            fi
            if [[ -f ${magento_ce_dir}/LICENSE_EE.txt ]] && [[ ! -L ${magento_ce_dir}/app/etc/enterprise ]]; then
                rm ${magento_ce_dir}/LICENSE_EE.txt
                rmdir ${magento_ce_dir}/app/etc/enterprise
            fi
        fi
    fi

    bash "${vagrant_dir}/scripts/host/relink_sample_data.sh" 2> >(logError)
else
    # Current installation is Composer-based
    warning "Switching between CE and EE is not possible for composer-based installation. Falling back to reinstall"
    if [[ ${upgrade_only} -eq 1 ]]; then
        rm "${magento_ce_dir}/composer.lock"
    fi
fi

bash "${vagrant_dir}/scripts/host/m_clear_cache.sh" 2> >(logError)
bash "${vagrant_dir}/scripts/host/m_composer.sh" install 2> >(logError)

if [[ ${host_os} == "Windows" ]] || [[ $(bash "${vagrant_dir}/scripts/get_config_value.sh" "guest_use_nfs") == 0 ]]; then
    read -p "$(warning "[Action Required] Wait while Magento2 code is uploaded in PhpStorm and press any key to continue...")" -n1 -s
fi

if [[ ${upgrade_only} -eq 1 ]]; then
    cd "${vagrant_dir}" && vagrant ssh -c 'chmod a+x ${MAGENTO_ROOT}/bin/magento' 2> >(logError)
    bash "${vagrant_dir}/m-bin-magento" "setup:upgrade" 2> >(logError)
    bash "${vagrant_dir}/m-bin-magento" "indexer:reindex" 2> >(logError)
    bash "${vagrant_dir}/m-clear-cache" 2> >(logError)
else
    bash "${vagrant_dir}/scripts/host/m_reinstall.sh" 2> >(logError)
fi

decrementNestingLevel
