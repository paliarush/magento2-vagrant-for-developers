#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/colors.sh"

default_log="${vagrant_dir}/log/debug.log"
log_file_path="${vagrant_dir}/scripts/.current_log_path"
nesting_level_file="${vagrant_dir}/scripts/.current_nesting_level"

function info() {
    echo "[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")${1}$(regular)$(sourceFile)$(regular)"
    log "[$(formattedDate)] INFO:$(getIndentationByNesting "$@")${1}$(sourceFile)]"
}

function status() {
    echo "[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")$(blue)${1}$(regular)$(sourceFile)$(regular)"
    log "[$(formattedDate)] STATUS:$(getIndentationByNesting "$@")${1}$(sourceFile)]"
}

function warning() {
    echo "[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")$(yellow)${1}$(regular)$(sourceFile)$(regular)"
    log "[$(formattedDate)] WARNING:$(getIndentationByNesting "$@")${1}$(sourceFile)]"
}

function error() {
    echo "[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")$(red)${1}$(regular)$(sourceFile)$(regular)"
    log "[$(formattedDate)] ERROR:$(getIndentationByNesting "$@")${1}$(sourceFile)]"
}

function success() {
    echo "[$(formattedDate)]$(getIndentationByNesting "$@")$(getStyleByNesting "$@")$(green)${1}$(regular)$(sourceFile)$(regular)"
    log "[$(formattedDate)] SUCCESS:$(getIndentationByNesting "$@")${1}$(sourceFile)]"
}

function filterVagrantOutput()
{
    if [[ -n "${1}" ]]; then
        input="${1}"
    else
        input="$(cat)"
    fi
    log "${input}"
    output="$(echo "${input}" | grep -i "\[.*\].*\[.*\]" | sed "s/.*\(\[.*\].*\[.*\]\)/\1/g")"
    if [[ -n "${output}" ]]; then
        echo "${output}"
    fi
}

function log() {
    if [[ -n "${1}" ]]; then
        input="${1}"
    else
        input="$(cat)"
    fi
    if [[ -n "${input}" ]]; then
        if [[ -f "${log_file_path}" ]]; then
            log_file="${vagrant_dir}/$(cat "${log_file_path}")"
        else
            log_file="${default_log}"
        fi
        echo "${input}" | sed "s/\[[[:digit:]]\{1,\}m//g" >> "${log_file}"
    fi
}

function logError() {
    if [[ -n "${1}" ]]; then
        input="${1}"
    else
        input="$(cat)"
    fi
    if [[ -n "${input}" ]]; then
        outputErrorsOnly "${input}"
        outputInfoOnly "${input}"
    fi
}

function sourceFile() {
    if [[ ! ${BASH_SOURCE[2]} =~ functions\.sh ]]; then
        echo " $(grey)[${BASH_SOURCE[2]}]"
    else
        echo " $(grey)[Unknown source file]"
    fi
}

function formattedDate() {
    date "+%Y-%m-%d %H:%M:%S"
}

function outputErrorsOnly()
{
    errors="$(echo "${1}" | grep -iv "Connection to 127.0.0.1 closed." \
        | grep -iv "Cloning into .*\.\.\."\
        | grep -iv "Checking out .* done\."\
    )"
    if [[ -n "${errors}" ]]; then
        error "${errors}"
        log "error: ${errors}"
    fi
}

function outputInfoOnly()
{
    info="$(echo "${1}" | grep -iv "Connection to 127.0.0.1 closed." \
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
        nesting_level="$(cat "${nesting_level_file}")"
        nesting_level="$((${nesting_level}+1))"
        echo ${nesting_level} > "${nesting_level_file}"
    fi
}

function decrementNestingLevel()
{
    if [[ -f "${nesting_level_file}" ]]; then
        nesting_level="$(cat "${nesting_level_file}")"
        nesting_level="$((${nesting_level}-1))"
        if [[ ${nesting_level} -eq 0 ]]; then
            rm -f "${nesting_level_file}"
        else
            echo ${nesting_level} > "${nesting_level_file}"
        fi
    fi
}

function resetNestingLevel()
{
    rm -f "${nesting_level_file}"
}

function initLogFile()
{
    if [[ -n "${1}" ]]; then
        log_file="${1}"
    else
        log_file="debug"
    fi
    echo "log/${log_file}.log" > "${log_file_path}"
    rm -f "${vagrant_dir}/log/${log_file}.log"
}

function getIndentationByNesting()
{
    if [[ ! -f "${nesting_level_file}" ]]; then
        nesting_level=0
        echo ' '
    else
        nesting_level="$(cat "${nesting_level_file}")"
        if [[ ${nesting_level} -eq 1 ]]; then
            echo ' >  '
        else
            indentation="$(( (${nesting_level} - 1) * 4 ))"
            echo "$(printf '=%.0s' $(seq 1 ${indentation})) >  " | sed 's|=| |g'
        fi
    fi
}

function getStyleByNesting()
{
    if [[ ! -f "${nesting_level_file}" ]]; then
        nesting_level=0
    else
        nesting_level="$(cat "${nesting_level_file}")"
    fi

    if [[ ${nesting_level} -eq 0 ]]; then
        echo "$(bold)"
    fi
}

function bash()
{
    $(which bash) "$@" 2> >(logError)
}
