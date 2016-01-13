# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

module OS
    def OS.is_windows
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end
end

module Config
    # Load and override config settings
    def Config.load
        local_config_dir = 'local.config'
        config_dist_file = local_config_dir + '/config.yaml.dist'
        config_file = local_config_dir + '/config.yaml'

        config_data_dist = YAML.load_file(config_dist_file)
        config_data = File.exists?(config_file) ? YAML.load_file(config_file) : {}
        return config_data_dist.merge!(config_data)
    end
end

# Get parameters from config file
config_data = Config.load
magento_host_name = config_data['magento']['host_name']
magento_ip_address = config_data['guest']['ip_address']
guest_memory = config_data['guest']['memory']

host_magento_dir = Dir.pwd + '/magento2ce'

VAGRANT_API_VERSION = 2
Vagrant.configure(VAGRANT_API_VERSION) do |config|
    config.vm.box = "ubuntu/trusty64"

    config.vm.provider "virtualbox" do |vb|
        vb.memory = guest_memory
    end

    config.vm.synced_folder '.', '/vagrant', disabled: true
    config.vm.synced_folder './local.config', '/vagrant/local.config'
    config.vm.synced_folder './scripts', '/vagrant/scripts'
    if OS.is_windows
        guest_magento_dir = '/var/www/magento2ce'
        config.vm.synced_folder host_magento_dir + '/var/generation', guest_magento_dir + '/var/generation'
        config.vm.synced_folder host_magento_dir + '/app/etc', guest_magento_dir + '/app/etc'
    else
        guest_magento_dir = host_magento_dir
        config.vm.synced_folder host_magento_dir, guest_magento_dir, type: "nfs"
    end

    shell_script_args = [
        OS.is_windows ? "1" : "0",                  #1
        guest_magento_dir,                          #2
        magento_host_name,                          #3
        config_data['guest']['use_php7'],           #4
        config_data['magento']['backend_frontname'],#5
        config_data['magento']['language'],         #6
        config_data['magento']['timezone'],         #8
        config_data['magento']['currency'],         #9
        config_data['magento']['admin_user'],       #9
        config_data['magento']['admin_password']    #10
    ]
    config.vm.provision "install_environment", type: "shell" do |s|
        s.path = "scripts/provision/install_environment.sh"
        s.args = shell_script_args
    end

    if OS.is_windows
        config.vm.provision "deploy_magento_code", type: "file", source: host_magento_dir, destination: '/var/www'
    end

    config.vm.provision "install_magento", type: "shell" do |s|
        s.path = "scripts/provision/install_magento.sh"
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
