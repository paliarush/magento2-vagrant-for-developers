# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

 * [\[Unreleased\]](#unreleased)
 * [\[v2.2.0\] - 2017-02-25](#v220---2017-02-25)
 * [\[v2.1.0\] - 2016-06-22](#v210---2016-06-22)
 * [\[v2.0.0\] - 2016-02-05](#v200---2016-02-05)
 * [\[v1.0.0\] - 2016-01-11](#v100---2016-01-11)

## [Unreleased]

### Changed

 - Verified compatibility with Vagrant 2.x and loosened Vagrant version requirement
 - Config option 'php_version' should now be used for PHP version selection instead of 'use_php7'
 - Upgraded Varnish to v4.1
 - Improved Magento re-installation speed by avoiding unnecessary cache cleaning
 - Custom code sniffer rules replaced with PSR2
 - MessageQueue module will now be installed with CE if using Magento v2.3+

### Added

 - PHP 7.1 and PHP 7.2 support
 - Support for new location of `generated` directory in Magento 2.2.0
 - Basic data generation can be turned off. Added configurable product and customer address generation 
 - Documentation in config.yaml.dist for choosing specific composer package versions

### Fixed

 - Magento 2.2.0 EE installation from composer

## [v2.2.0] - 2017-02-25

### Changed

 - Magento EE and sample data directories are added to 'Exclude list' in PhpStorm
 - Redis is used as default cache backend instead of filesystem
 - After EE is linked, EE versions of composer.lock and composer.json are replaced back with CE versions (thus are not marked by git as modified)
 - Improved CLI scripts output formatting

### Fixed

 - Issue with some files marked as unversioned in git after EE linking
 - It is now possible to use spaces in path to vagrant project on Windows. On OSX and Linux hosts it works in non-NFS mode, in NFS mode it does not work because of [bug in vagrant](mitchellh/vagrant#7540)
 - Issue with MySQL being down after VM power off

### Added

 - Added ability to configure number of CPUs for virtual machine via [etc/config.yaml](etc/config.yaml.dist)
 - Added generation of basic sample data for testing purposes
 - Ability to upgrade Magento using `m-switch-to-ce` and `m-switch-to-ee` (when `-u` flag is specified)
 - Redis support for Magento caching
 - Access to Magento developer mode and storefront/admin UI debugging features via [etc/config.yaml](etc/config.yaml.dist)
 - Composer-based installation support
 - Magento cache warming up after re-install and clearing cache (when `-w` flag is specified)
 - Tests configuration files are generated during project initialization
 - Sample data support
 - ElasticSearch support
 - NodeJS, NPM, Gulp and Grunt are installed as part of the provisioning process

## [v2.1.0] - 2016-06-22

### Changed

 - Removed requirement for public github token due to Composer limitations (issue is fixed on Composer side)
 - Changed requirement for minimum box version from 1.0 to 1.1
 - Upgraded PHP 5.5.9 to PHP 5.6
 - When [init_project.sh](init_project.sh) is executed, EE will be installed by default, if EE repository is specified in [etc/config.yaml](etc/config.yaml.dist). Not supported on Windows hosts

### Fixed

 - Permissions during Magento installation on Windows hosts
 - Issue with Magento compiler on Windows hosts
 - "stdin: is not a tty" warning

### Added

 - Setup and upgrade cron scripts to crontab
 - Logging of all emails in HTML format to `vagrant-magento/log/email`
 - Host wrapper script for bin/magento command on guest
 - Ability to modify guest config files (PHP, Apache etc) directly from host IDE
 - Ability to choose if PhpStorm configs should be removed during project reinitialization
 - Ability to switch PHP version without destroying the project ("vagrant reload" is required)
 - Ability to do force switch to CE or EE (even if already switched to target edition)
 - Ability to use Varnish full page caching automatically. (Using "vagrant reload" or m-varnish script)

## [v2.0.0] - 2016-02-05

### Changed

 - Moved provisioning scripts
 - Magento project directory moved to vagrant project root. Current structure is as follows: `vagrant-magento/magento2ce/magento2ee`
 - PHP 7.0 is installed by default instead of PHP 5.5.9 (can be configured in [etc/config.yaml](etc/config.yaml.dist))
 - Renamed configuration folder from `local.config` to `etc`
 - Set minimum Vagrant version as 1.8
 - Improved deployment speed in case of disabled NFS for folders sync
 - Used custom Vagrant box with pre-installed software necessary for Magento 2 development
 - Eliminated explicit dependency on PHP for Windows hosts (it can be downloaded and used locally for the project)
 - XSD URN generation is executed after Magento installation

### Added

 - Added [project initialization script](init_project.sh) and host scripts for routine flows (compatible with OSX, *nix and Windows)
 - Implemented static value of forwarded SSH port to prevent necessity to reconfigure software accessing guest via SSH
 - Implemented collision prevention for IP address and host name (in case when several machines are created at once)
 - Configuration file [etc/config.yaml](etc/config.yaml.dist)
 - PHP 7.0 support
 - PHP Storm configuration during project initialization (particularly automatic deployment settings)
 - Automatic vagrant plugins installation

## [v1.0.0] - 2016-01-11

### Added

 - Integrated vagrant host manager plugin to allow automatic /etc/hosts update
 - Support of EE linked to CE using symlinks on *nix hosts
 - ${MAGENTO_ROOT} environment variable, which stores installation path on the guest
 - Support of Rabbit MQ
 - Possibility to specify tokens for repo.magento.com composer repository
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
