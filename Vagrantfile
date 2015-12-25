# -*- mode: ruby -*-
# vi: set ft=ruby :

module OS
    def OS.is_windows
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end
end

require 'pathname.rb'
host_magento_dir = Pathname.new(Dir.pwd + '/../magento2ce').realpath.to_s

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/trusty64"

    config.vm.provider "virtualbox" do |vb|
        vb.memory = 3072 # Around 3Gb is necessary to be able to run tests
    end
    config.vm.network :private_network, ip: '192.168.10.11'
    config.vm.hostname = "magento2.vagrant"

    config.vm.synced_folder '.', '/vagrant'
    if OS.is_windows
        guest_magento_dir = '/var/www/magento2ce'
        config.vm.synced_folder host_magento_dir + '/var/generation', guest_magento_dir + '/var/generation'
        config.vm.synced_folder host_magento_dir + '/app/etc', guest_magento_dir + '/app/etc'
    else
        guest_magento_dir = host_magento_dir
        config.vm.synced_folder host_magento_dir, guest_magento_dir, type: "nfs"
    end

    config.vm.provision "install_environment", type: "shell" do |s|
        s.path = "install_environment.sh"
        s.args = [
            OS.is_windows ? "1" : "0",
            guest_magento_dir
        ]
    end

    if OS.is_windows
        config.vm.provision "deploy_magento_code", type: "file", source: host_magento_dir, destination: '/var/www'
    end

    config.vm.provision "install_magento", type: "shell" do |s|
        s.path = "install_magento.sh"
        s.args = [
            OS.is_windows ? "1" : "0",
            guest_magento_dir
        ]
    end
end
