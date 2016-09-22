# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

 * [\[Unreleased\]](#unreleased)
 * [\[v2.1.0\] - 2016-06-22](#v210---2016-06-22)
 * [\[v2.0.0\] - 2016-02-05](#v200---2016-02-05)
 * [\[v1.0.0\] - 2016-01-11](#v100---2016-01-11)

## [Unreleased]

### Changed

 - After EE is linked, EE versions of composer.lock and composer.json are replaced back with CE versions (thus are not marked by git as modified)
 - Improved CLI scripts output formatting

### Fixed

 - Fixed issue with some files marked as unversioned in git after EE linking
 - It is now possible to use spaces in path to vagrant project on Windows. On OSX and Linux hosts it works in non-NFS mode, in NFS mode it does not work because of [bug in vagrant](mitchellh/vagrant#7540)
 - Fixed issue with MySQL being down after VM power off

### Added

 - Added sample data support
 - Added ElasticSearch support

## [v2.1.0] - 2016-06-22

### Changed

 - Removed requirement for public github token due to Composer limitations (issue is fixed on Composer side)
 - Changed requirement for minimum box version from 1.0 to 1.1
 - Upgraded PHP 5.5.9 to PHP 5.6
 - When [init_project.sh](init_project.sh) is executed, EE will be installed by default, if EE repository is specified in [etc/config.yaml.dist](etc/config.yaml.dist). Not supported on Windows hosts

### Fixed

 - Fixed permissions during Magento installation on Windows hosts
 - Fixed issue with Magento compiler on Windows hosts
 - Fixed "stdin: is not a tty" warning

### Added

 - Added setup and upgrade cron scripts to crontab
 - Added logging of all emails in HTML format to `vagrant-magento/log/email`
 - Added host wrapper script for bin/magento command on guest
 - Added ability to modify guest config files (PHP, Apache etc) directly from host IDE
 - Added ability to choose if PhpStorm configs should be removed during project reinitialization
 - Added ability to switch PHP version without destroying the project ("vagrant reload" is required)
 - Added ability to do force switch to CE or EE (even if already switched to target edition)
 - Added ability to use Varnish full page caching automatically. (Using "vagrant reload" or m-varnish script)

## [v2.0.0] - 2016-02-05

### Changed

 - Moved provisioning scripts
 - Magento project directory moved to vagrant project root. Current structure is as follows: `vagrant-magento/magento2ce/magento2ee`
 - PHP 7.0 is installed by default instead of PHP 5.5.9 (can be configured in [etc/config.yaml.dist](etc/config.yaml.dist))
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
 - Added configuration file [etc/config.yaml.dist](etc/config.yaml.dist)
 - Added PHP 7.0 support
 - Added PHP Storm configuration during project initialization (particularly automatic deployment settings)
 - Added automatic vagrant plugins installation

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
