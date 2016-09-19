#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"
incrementNestingLevel

os_name="$(uname)"
if [[ "${os_name}" == "Darwin" ]]; then
    echo "OSX"
elif [[ "$(expr substr "${os_name}" 1 5)" == "Linux" ]]; then
    echo "Linux"
elif [[ "$(expr substr "${os_name}" 1 5)" == "MINGW" ]]; then
    echo "Windows"
elif [[ "$(expr substr "${os_name}" 1 6)" == "CYGWIN" ]]; then
    echo "Windows"
else
    echo "Unknown host OS: ${os_name}"
    decrementNestingLevel
    exit 1
fi

decrementNestingLevel
