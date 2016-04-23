#!/usr/bin/env bash

link_configs

# Make sure configs are restored on system halt and during reboot
if [ ! -f /etc/init.d/K04-unlink-configs ]; then
    ln -s /vagrant/scripts/guest/unlink_configs /etc/init.d/K04-unlink-configs
    ln -s /etc/init.d/K04-unlink-configs /etc/rc0.d/K04-unlink-configs
    ln -s /etc/init.d/K04-unlink-configs /etc/rc6.d/K04-unlink-configs
fi