#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.."; pwd)

source "${vagrant_dir}/scripts/functions.sh"
incrementNestingLevel

if [[ "$(uname)" == "Darwin" ]]; then
    echo "OSX"
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
    echo "Linux"
elif [[ "$(expr substr $(uname -s) 1 5)" == "MINGW" ]]; then
    echo "Windows"
elif [[ "$(expr substr $(uname -s) 1 6)" == "CYGWIN" ]]; then
    echo "Windows"
else
    echo "Unknown host OS"
    decrementNestingLevel
    exit 1
fi

decrementNestingLevel
