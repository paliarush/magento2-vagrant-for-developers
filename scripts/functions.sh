#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd)

source "${vagrant_dir}/scripts/colors.sh"

log_file="${vagrant_dir}/log/debug.log"
nesting_level_file="${vagrant_dir}/scripts/.current_nesting_level"

function info() {
    echo "
[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}"
    log "[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")info: ${1} [${BASH_SOURCE[1]}]"
}

function status() {
    echo "
[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")${blue}${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}"
    log "[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")status: ${1} [${BASH_SOURCE[1]}]"
}

function warning() {
    echo "
[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")${yellow}${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}"
    log "[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")warning: ${1} [${BASH_SOURCE[1]}]"
}

function error() {
    echo "
[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")${red}${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}"
    log "[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")error: ${1} [${BASH_SOURCE[1]}]"
}

function success() {
    echo "
[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")${green}${1}${regular} ${grey}[${BASH_SOURCE[1]}]${regular}"
    log "[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")success: ${1} [${BASH_SOURCE[1]}]"
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

function incrementNestingLevel()
{
    if [[ ! -f "${nesting_level_file}" ]]; then
        echo 1 > "${nesting_level_file}"
    else
        nesting_level=$(cat "${nesting_level_file}")
        nesting_level=$((${nesting_level}+1))
        echo ${nesting_level} > "${nesting_level_file}"
    fi
}

function decrementNestingLevel()
{
    if [[ -f "${nesting_level_file}" ]]; then
        nesting_level=$(cat "${nesting_level_file}")
        nesting_level=$((${nesting_level}-1))
        if [[ ${nesting_level} -eq 0 ]]; then
            rm -f "${nesting_level_file}"
        else
            echo ${nesting_level} > "${nesting_level_file}"
        fi
    fi
}

function getIndentationByNesting()
{
    if [[ ! -f "${nesting_level_file}" ]]; then
        nesting_level=0
    else
        nesting_level=$(cat "${nesting_level_file}")
        if [[ ${nesting_level} -eq 1 ]]; then
            echo '|---'
        else
            indentation=$(( (${nesting_level} - 1) * 4 ))
            echo "$(printf '=%.0s' $(seq 1 ${indentation}))|---" | sed 's|=| |g'
        fi
    fi
}

function getStyleByNesting()
{
    if [[ ! -f "${nesting_level_file}" ]]; then
        nesting_level=0
    else
        nesting_level=$(cat "${nesting_level_file}")
    fi

    if [[ ${nesting_level} -eq 0 ]]; then
        echo "${bold}"
    fi
}

function bash()
{
    incrementNestingLevel
    $(which bash) "$@" 2> >(logError)
    decrementNestingLevel
}
