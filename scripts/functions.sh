#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd)

source "${vagrant_dir}/scripts/colors.sh"

log_file="${vagrant_dir}/log/debug.log"

function info() {
    echo "
[$(formattedDate)] ${blue}${bold} ${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}
"
    log "[$(formattedDate)]  ## info: ${1} [${BASH_SOURCE[1]}]"
}

function infoLevel2() {
    echo "
[$(formattedDate)] ${blue}${bold} ${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}
"
    log "[$(formattedDate)]  #### info: ${1} [${BASH_SOURCE[1]}]"
}

function warning() {
    echo "
[$(formattedDate)]  ${yellow}${bold}${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}
"
    log "[$(formattedDate)]  warning: ${1} [${BASH_SOURCE[1]}]"
}

function error() {
    echo "
[$(formattedDate)]  ${red}${bold}${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}
"
    log "[$(formattedDate)]  ## error: ${1} [${BASH_SOURCE[1]}]"
}

function success() {
    echo "
[$(formattedDate)]  ${green}${bold}${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}
"
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
        echo "${regular}${red}${input}${regular}"
        echo "error: ${input}" >> "${log_file}"
    fi
}

function formattedDate() {
    date "+%Y-%m-%d %H:%M:%S"
}
