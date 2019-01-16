#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/functions.sh"

status "Checking requirements"
incrementNestingLevel

nfs_exports_record="\"${vagrant_dir}\" -alldirs -mapall=$(id -u):$(id -g) -mask 255.0.0.0 -network 192.0.0.0"
if [[ -z "$(grep "${nfs_exports_record}" /etc/exports)" ]]; then
    warning "NFS exports configuration required on the host. Please execute 'sudo ${vagrant_dir}/scripts/host/configure_nfs_exports.sh' first."
    exit 1
fi

decrementNestingLevel
