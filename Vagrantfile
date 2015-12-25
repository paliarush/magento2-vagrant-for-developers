# -*- mode: ruby -*-
# vi: set ft=ruby :

module OS
    def OS.is_windows
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end
end

require 'pathname.rb'
host_magento_dir = Pathname.new(Dir.pwd + '/../magento2ce').realpath.to_s
magento_host_name = 'magento2.vagrant'
magento_ip_address = '192.168.10.11'

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/trusty64"

    config.vm.provider "virtualbox" do |vb|
        vb.memory = 3072 # Around 3Gb is necessary to be able to run tests
    end

    config.vm.synced_folder '.', '/vagrant'
    if OS.is_windows
        guest_magento_dir = '/var/www/magento2ce'
        config.vm.synced_folder host_magento_dir + '/var/generation', guest_magento_dir + '/var/generation'
        config.vm.synced_folder host_magento_dir + '/app/etc', guest_magento_dir + '/app/etc'
    else
        guest_magento_dir = host_magento_dir
        config.vm.synced_folder host_magento_dir, guest_magento_dir, type: "nfs"
    end

    shell_script_args = [
        OS.is_windows ? "1" : "0",
        guest_magento_dir,
        magento_host_name
    ]
    config.vm.provision "install_environment", type: "shell" do |s|
        s.path = "install_environment.sh"
        s.args = shell_script_args
    end

    if OS.is_windows
        config.vm.provision "deploy_magento_code", type: "file", source: host_magento_dir, destination: '/var/www'
    end

    config.vm.provision "install_magento", type: "shell" do |s|
        s.path = "install_magento.sh"
        s.args = shell_script_args
    end

    # Host manager plugin configuration
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
    config.vm.define magento_host_name do |node|
        node.vm.hostname = magento_host_name
        node.vm.network :private_network, ip: magento_ip_address
    end
end
