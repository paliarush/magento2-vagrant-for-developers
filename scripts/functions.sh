#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd)

source "${vagrant_dir}/scripts/colors.sh"

log_file="${vagrant_dir}/log/debug.log"



function info() {
    echo "
[$(formattedDate)] ${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}"
    log "[$(formattedDate)]  ## info: ${1} [${BASH_SOURCE[1]}]"
}

function status() {
    echo "
[$(formattedDate)] ${blue}${bold} ${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}"
    log "[$(formattedDate)]  ## status: ${1} [${BASH_SOURCE[1]}]"
}

function statusLevel2() {
    echo "[$(formattedDate)]    ${blue}${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}"
    log "[$(formattedDate)]  #### status: ${1} [${BASH_SOURCE[1]}]"
}

function warning() {
    echo "
[$(formattedDate)]  ${yellow}${bold}${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}"
    log "[$(formattedDate)]  ## warning: ${1} [${BASH_SOURCE[1]}]"
}

function error() {
    echo "
[$(formattedDate)]  ${red}${bold}${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}"
    log "[$(formattedDate)]  ## error: ${1} [${BASH_SOURCE[1]}]"
}

function success() {
    echo "
[$(formattedDate)]  ${green}${bold}${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}"
    log "[$(formattedDate)]  ## success: ${1} [${BASH_SOURCE[1]}]"
}

function log() {
    if [[ -n "${1}" ]]; then
        input="${1}"
    else
        input=$(cat)
    fi
    if [[ -n "${input}" ]]; then
        echo "
${input}
" >> "${log_file}"
    fi
}

function logError() {
    if [[ -n "${1}" ]]; then
        input="${1}"
    else
        input=$(cat)
    fi
    if [[ -n "${input}" ]]; then
        outputErrorsOnly "${input}"
        outputInfoOnly "${input}"
    fi
}

function formattedDate() {
    date "+%Y-%m-%d %H:%M:%S"
}

function outputErrorsOnly()
{
    errors="$(echo "${1}" | grep -iv "Connection to 127.0.0.1 closed." \
        | grep -iv "Loading composer repositories with package information" \
        | grep -iv "Installing dependencies (including require-dev) from lock file" \
        | grep -iv "Nothing to install or update"\
        | grep -iv "Package fabpot/php-cs-fixer is abandoned"\
        | grep -iv "Generating autoload files"\
        | grep -iv "Installing .*/.* (.*)"\
        | grep -iv "Loading from cache"\
        | grep -iv ".* suggests installing .*"\
        | grep -iv "Cloning into .*\.\.\."\
        | grep -iv "Checking out .* done\."\
    )"
    if [[ -n "${errors}" ]]; then
        echo "${regular}${red}${errors}${regular}
"
        log "error: ${errors}"
    fi
}

function outputInfoOnly()
{
    info="$(echo "${1}" | grep -iv "Connection to 127.0.0.1 closed." \
        | grep -i "Loading composer repositories with package information" \
        | grep -i "Installing dependencies (including require-dev) from lock file" \
        | grep -i "Nothing to install or update"\
        | grep -i "Package fabpot/php-cs-fixer is abandoned"\
        | grep -i "Generating autoload files"\
        | grep -i "Installing .*/.* (.*)"\
        | grep -i "Loading from cache"\
        | grep -i ".* suggests installing .*"\
        | grep -i "Cloning into .*\.\.\."\
        | grep -i "Checking out .* done\."\
    )"
    if [[ -n "${info}" ]]; then
        log "${info}"
    fi
}
