#!/usr/bin/env bash

function isServiceAvailable() {
    all_services="$(service --status-all 2> >(log))"
    if [[ ${all_services} =~ ${1} ]]; then
        echo 1
    else
        echo 0
    fi
}

use_php7=$4
vagrant_dir="/vagrant"

source "${vagrant_dir}/scripts/output_functions.sh"

status "Upgrading environment (recurring)"
incrementNestingLevel

status "Fixing potential issue with MySQL being down after VM power off"
service mysql restart 2> >(logError) > >(log)

decrementNestingLevel
