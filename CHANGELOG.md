# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

 * [\[Unreleased\]](#unreleased)
 * [\[v1.0.0\] - 2016-01-11](#v100---2016-01-11)

## [Unreleased]

### Changed

 - Moved provisioning scripts
 - Magento project directory moved to vagrant project root. Current structure is as follows: `vagrant-magento/magento2ce/magento2ee`
 - PHP 7.0 is installed by default instead of PHP 5.5.9 (can be configured in [local.config/config.yaml.dist](local.config/config.yaml.dist))

### Added

 - Implemented static value of forwarded SSH port to prevent necessity to reconfigure software accessing guest via SSH
 - Implemented collision prevention for IP address and host name (in case when several machines are created at once)
 - Added configuration file [local.config/config.yaml.dist](local.config/config.yaml.dist)
 - Added PHP 7.0 support
 - Added PHP Storm configuration during project initialization
 - Added [project initialization script](init_project.sh) for *nix and OSX hosts 
 - Added ability to customize repository URLs and Apache config

## [v1.0.0] - 2016-01-11

### Added

 - Integrated vagrant host manager plugin to allow automatic /etc/hosts update 
 - Added support of EE linked to CE using symlinks on *nix hosts 
 - Added ${MAGENTO_ROOT} environment variable, which stores installation path on the guest
 - Added support of Rabbit MQ
 - Added possibility to specify tokens for repo.magento.com composer repository 
 - git is now installed on guest machine
 - Removed 'magento' MySQL user, password of 'root' user removed 
 - Database for integration tests are created by default 
 - Added script for clearing Magento cache from host command line 
 - Configured XDebug to allow remote debugging
 - Fixed max_nesting_level issue with XDebug enabled  
 - Apache is run by 'vagrant' user
 - Enabled Magento cron jobs 
 - Enabled XDebug by default
 - Created vagrant configuration for Magneto 2 CE developer's environment installation
