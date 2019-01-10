#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/functions.sh"

cd "${vagrant_dir}"

# TODO: parameterize container

arguments=$@
executeInMagento2Container -- "/var/www/html/scripts/guest/composer.sh" ${arguments} 2> >(logError)
