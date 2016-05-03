#!/usr/bin/env bash

# Enable trace printing and exit on the first error
set +x

vagrant_dir="/vagrant"

# Remove configs from host in case of force stop of virtual machine before linking restored ones
cd ${vagrant_dir}/etc && mv guest/.gitignore guest_gitignore.back && rm -rf guest && mkdir guest && mv guest_gitignore.back guest/.gitignore
bash ${vagrant_dir}/scripts/guest/link_configs

# Make sure configs are restored on system halt and during reboot
rm -f /etc/init.d/unlink-configs
cp ${vagrant_dir}/scripts/guest/unlink_configs /etc/init.d/unlink-configs
if [ ! -f /etc/rc0.d/K04-unlink-configs ]; then
    ln -s /etc/init.d/unlink-configs /etc/rc0.d/K04-unlink-configs
    ln -s /etc/init.d/unlink-configs /etc/rc1.d/S04-unlink-configs
    ln -s /etc/init.d/unlink-configs /etc/rc2.d/S04-unlink-configs
    ln -s /etc/init.d/unlink-configs /etc/rc3.d/S04-unlink-configs
    ln -s /etc/init.d/unlink-configs /etc/rc4.d/S04-unlink-configs
    ln -s /etc/init.d/unlink-configs /etc/rc5.d/S04-unlink-configs
    ln -s /etc/init.d/unlink-configs /etc/rc6.d/K04-unlink-configs
fi

# Upgrade existing environment
if [ -f ${vagrant_dir}/.idea/deployment.xml ]; then
    sed -i.back "s|magento2ce/var/generation|magento2ce/var|g" "${vagrant_dir}/.idea/deployment.xml"
fi