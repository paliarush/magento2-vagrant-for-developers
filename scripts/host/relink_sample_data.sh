#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"

magento_ce_dir="${vagrant_dir}/magento2ce"
magento_ee_dir="${magento_ce_dir}/magento2ee"
magento_ce_sample_data_dir="${magento_ce_dir}/magento2ce-sample-data"
magento_ee_sample_data_dir="${magento_ce_dir}/magento2ee-sample-data"
php_executable="$(bash "${vagrant_dir}/scripts/host/get_path_to_php.sh")"
install_sample_data="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "magento_install_sample_data")"

status "Linking/unlinking sample data according to config.yaml"
incrementNestingLevel

install_ee=0
if [[ -f "${magento_ce_dir}/LICENSE_EE.txt" ]]; then
    install_ee=1
fi

# As a precondition, disable CE sample data
if [[ -f "${magento_ce_sample_data_dir}/dev/tools/build-sample-data.php" ]]; then
    status "Unlinking CE sample data"
    ${php_executable} -f "${magento_ce_sample_data_dir}/dev/tools/build-sample-data.php" -- --command=unlink --ce-source="${magento_ce_dir}" --sample-data-source="${magento_ce_sample_data_dir}" --exclude=true 2> >(logError) > >(log)
fi
# As a precondition, disable EE sample data
if [[ -f "${magento_ee_sample_data_dir}/dev/tools/build-sample-data.php" ]]; then
    "${php_executable}" -f "${magento_ee_sample_data_dir}/dev/tools/build-sample-data.php" -- --command=unlink --ce-source="${magento_ce_dir}" --sample-data-source="${magento_ee_sample_data_dir}" --exclude=true 2> >(logError) > >(log)
    status "Unlinking EE sample data"
fi

if [[ ${install_ee} -eq 1 ]]; then
    status "Linking EE to CE"
    "${php_executable}" -f "${magento_ee_dir}/dev/tools/build-ee.php" -- --command=link --ee-source="${magento_ee_dir}" --ce-source="${magento_ce_dir}" --exclude=true 2> >(logError) > >(log)
fi

if [[ ${install_sample_data} -eq 1 ]]; then
    # Installing CE or EE, in both cases CE sample data should be linked
    if [[ ! -f "${magento_ce_sample_data_dir}/dev/tools/build-sample-data.php" ]]; then
        # Sample data not available and should be enabled
        error "CE Sample data repository is not available. Recreate project using \"init_project.sh -fc\", which will delete Magento code base and recreate project from scratch. Or clone sample data to ${magento_ce_sample_data_dir}"
        decrementNestingLevel
        exit 1
    else
        # Sample data available and should be enabled
        success "CE Sample data enabled"
        cd ${magento_ce_sample_data_dir} && git fetch && git pull 2> >(logError) > >(log)
        "${php_executable}" -f "${magento_ce_sample_data_dir}/dev/tools/build-sample-data.php" -- --command=link --ce-source="${magento_ce_dir}" --sample-data-source="${magento_ce_sample_data_dir}" --exclude=true 2> >(logError) > >(log)
    fi

    if [[ ${install_ee} -eq 1 ]]; then
        # Installing EE
        if [[ ! -f "${magento_ee_sample_data_dir}/dev/tools/build-sample-data.php" ]]; then
            # Sample data not available and should be enabled
            error "EE Sample data repository is not available. Recreate project using \"init_project.sh -fc\", which will delete Magento code base and recreate project from scratch. Or clone sample data to ${magento_ee_sample_data_dir}."
            decrementNestingLevel
            exit 1
        else
            # Sample data available and should be enabled
            success "EE Sample data enabled"
            cd ${magento_ee_sample_data_dir} && git fetch && git pull 2> >(logError) > >(log)
            "${php_executable}" -f "${magento_ee_sample_data_dir}/dev/tools/build-sample-data.php" -- --command=link --ce-source="${magento_ce_dir}" --sample-data-source="${magento_ee_sample_data_dir}" --exclude=true 2> >(logError) > >(log)
        fi
    fi
fi

decrementNestingLevel
