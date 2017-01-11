# Vagrant project for Magento 2 developers (optimized for Mac, Windows and \*nix hosts)

[![Tests passing on OSX](docs/images/tests_badge.png)](https://github.com/paliarush/magento2-vagrant-for-developers-tests)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Semver](http://img.shields.io/SemVer/2.0.0.png?color=blue)](http://semver.org/spec/v2.0.0.html)
[![Latest GitHub release](docs/images/release_badge.png)](https://github.com/paliarush/magento2-vagrant-for-developers/releases/latest)

 * [What You get](#what-you-get)
 * [How to install](#how-to-install)
   * [Requirements](#requirements)
   * [Installation steps](#installation-steps)
   * [Default credentials and settings](#default-credentials-and-settings)
   * [Getting updates and fixes](#getting-updates-and-fixes)
 * [Day-to-day development scenarios](#day-to-day-development-scenarios)
   * [Reinstall Magento](#reinstall-magento)
   * [Clear Magento cache](#clear-magento-cache)
   * [Switch between CE and EE](#switch-between-ce-and-ee)
   * [Sample data installation](#sample-data-installation)
   * [Use Magento CLI (bin/magento)](#use-magento-cli-binmagento)
   * [Debugging with XDebug](#debugging-with-xdebug)
   * [Connecting to MySQL DB](#connecting-to-mysql-db)
   * [View emails sent by Magento](#view-emails-sent-by-magento)
   * [Accessing PHP and other config files](#accessing-php-and-other-config-files)
   * [Upgrading Magento](#upgrading-magento)
   * [Multiple Magento instances](#multiple-magento-instances)
   * [Update Composer dependencies](#update-composer-dependencies)
 * [Environment configuration](#environment-configuration)
   * [Switch between PHP 5.6 and 7.0](#switch-between-php-56-and-70)
   * [Activating Varnish](#activating-varnish)
   * [Activating ElasticSearch](#activating-elasticsearch)
   * [Redis for caching](#redis-for-caching)
   * [Reset environment](#reset-environment)
 * [FAQ](#faq)

## What You get

It is expected that Magento 2 project source code will be located and managed on the host. This is necessary to allow quick indexing of project files by IDE. All other infrastructure is deployed on the guest machine.

Current Vagrant configuration aims to solve performance issues of Magento installed on Virtual Box **for development**. Custom solution is implemented for Windows hosts. See [explanation of the proposed solution](docs/performance-issue-on-windows-hosts.md).

Environment for Magento EE development is configured as well.

It is easy to [install multiple Magento instances](#multiple-magento-instances) based on different codebases simultaneously.

[Project initialization script](init_project.sh) configures complete development environment:

 1. Adds some missing software on the host
 1. Configures all software necessary for Magento 2 using [custom Ubuntu vagrant box](https://atlas.hashicorp.com/paliarush/boxes/magento2.ubuntu) (Apache 2.4, PHP 7.0 (or 5.6), MySQL 5.6, Git, Composer, XDebug, Rabbit MQ, Varnish)
 1. Installs Magento 2 from Git repositories or Composer packages (can be configured via `checkout_source_from` option in [etc/config.yaml](etc/config.yaml.dist))
 1. Configures PHP Storm project (partially at the moment)
 1. Installs NodeJS, NPM, Grunt and Gulp for front end development

## How to install

If you never used Vagrant before, read [Vagrant Docs](https://docs.vagrantup.com/v2)

### Requirements

Software listed below should be available in [PATH](https://en.wikipedia.org/wiki/PATH_\(variable\)) (except for PHP Storm).

- [Vagrant 1.8+](https://www.vagrantup.com/downloads.html)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git). Make sure you have SSH keys generated and associated with your github account, see [how to check](https://help.github.com/articles/testing-your-ssh-connection/) and [how to configure](https://help.github.com/articles/generating-ssh-keys/) if not configured.<br />
:information_source: It is possible to use another way of getting codebase instead of cloning, it does not matter for successful installation. Just put Magento 2 codebase inside of `vagrant-magento/magento2ce`.<br />
:information_source: ![](docs/images/windows-icon.png) On Windows hosts Git must be [v2.7+](http://git-scm.com/download/win), also make sure to set the following options to avoid issues with incorrect line separators:

    ```
    git config --global core.autocrlf false
    git config --global core.eol LF
    git config --global diff.renamelimit 5000
    ```
- ![](docs/images/linux-icon.png)![](docs/images/osx-icon.png) [PHP](http://php.net/manual/en/install.php) (any version) to allow Magento dependency management with [Composer](https://getcomposer.org/doc/00-intro.md)
- [PHP Storm](https://www.jetbrains.com/phpstorm) is optional but recommended.
- ![](docs/images/linux-icon.png)![](docs/images/osx-icon.png) [NFS server](https://en.wikipedia.org/wiki/Network_File_System) must be installed and running on \*nix and OSX hosts. Is usually available, so just try to follow [installation steps](#how-to-install) first.

### Installation steps

:information_source: In case of any issues during installation, please read [FAQ section](#faq)

 1. Open terminal and change directory to the one which you want to contain Magento project. ![](docs/images/windows-icon.png) On Windows use Git Bash, which is available after Git installation

 1. Download project with Vagrant configuration. :warning: Do not open it in PhpStorm until `init_project.sh` has completed PhpStorm configuration:

   ```
   git clone git@github.com:paliarush/magento2-vagrant-for-developers.git vagrant-magento
   ```

 1. Optionally, if you use private repositories on GitHub or download packages from Magento Marketplace using Composer

   - copy [etc/composer/auth.json.dist](etc/composer/auth.json.dist) to `etc/composer/auth.json`
   - specify your GitHub token by adding `"github.com": "your-github-token"` to `github-oauth` section for GitHub authorization
   - add Magento Marketplace keys for Marketplace authorization to `repo.magento.com` section

 1. Optionally, copy [etc/config.yaml.dist](etc/config.yaml.dist) as `etc/config.yaml` and make necessary customizations

 1. Initialize project (this will configure environment, install Magento, configure PHPStorm project):

   ```
   cd vagrant-magento
   bash init_project.sh
   ```

 1. Use `vagrant-magento` directory as project root in PHP Storm (not `vagrant-magento/magento2ce`). This is important, because in this case PHP Storm will be configured automatically by [init_project.sh](init_project.sh). If NFS files sync is disabled in [config](etc/config.yaml.dist) and ![](docs/images/windows-icon.png) on Windows hosts [verify deployment configuration in PHP Storm](docs/phpstorm-configuration-windows-hosts.md)

 1. Configure remote PHP interpreter in PHP Storm. Go to `Settings => Languages & Frameworks => PHP`, add new remote interpreter and select "Deployment configuration" as a source for connection details.

### Default credentials and settings

Some of default settings are available for override. These settings can be found in the file [etc/config.yaml.dist](etc/config.yaml.dist).
To override settings just create a copy of the file under the name 'config.yaml' and put there your custom settings.
When using [init_project.sh](init_project.sh), if not specified manually, random IP address is generated and is used as suffix for host name to prevent collisions, in case when 2 or more instances are running at the same time.
Upon a successful installation, you'll see the location and URL of the newly-installed Magento 2 application in console.

**Web access**:
- Access storefront at `http://magento2.vagrant<random_suffix>`
- Access admin panel at `http://magento2.vagrant<random_suffix>/admin/`
- Magento admin user/password: `admin/123123q`
- Rabbit MQ control panel: `http://magento2.vagrant<random_suffix>:15672`, credentials `guest`/`guest`

**Codebase and DB access**:
- Path to your Magento installation on the VM:
  - Can be retrieved from environment variable: `echo ${MAGENTO_ROOT}`
  - ![](docs/images/windows-icon.png) On Windows hosts: `/var/www/magento2ce`
  - ![](docs/images/linux-icon.png)![](docs/images/osx-icon.png) On Mac and \*nix hosts: the same as on host
- MySQL DB host: `localhost` (not accessible remotely)
- MySQL DB name: `magento`, `magento_integration_tests`
- MySQL DB user/password: `root:<no password>`. In CLI just use `mysql` with no user and password (`root:<no password>` will be used by default)

**Codebase on host**
- CE codebase: `vagrant_project_root/magento2ce`
- EE codebase will be available if path to EE repository is specified in `etc/config.yaml`: `vagrant_project_root/magento2ce/magento2ee`

### Getting updates and fixes

Current vagrant project follows [semantic versioning](http://semver.org/spec/v2.0.0.html) so feel free to pull the latest features and fixes, they will not break your project.
For example your current branch is `2.0`, then it will be safe to pull any changes from `origin/2.0`. However branch `3.0` will contain changes backward incompatible with `2.0`.
Note, that semantic versioning is only used for `x.0` branches (not for `develop`).

:information_source: To apply changes run `vagrant reload`.

## Day-to-day development scenarios

### Reinstall Magento

Use commands described in [Switch between CE and EE](#switch-between-ce-and-ee) section with `-f` flag. Before doing actual re-installation, these commands update linking of EE codebase, clear cache, update composer dependencies.

If no composer update and relinking of EE codebase is necessary, use the following command. It will clear Magento DB, Magento caches and reinstall Magento instance.

Go to the root of vagrant project in command line and execute:

```
bash m-reinstall
```

### Clear Magento cache

Go to the root of vagrant project in command line and execute:

```
bash m-clear-cache
```

### Switch between CE and EE

Assume, that EE codebase is available in `vagrant_project_root/magento2ce/magento2ee`.
The following commands will link/unlink EE codebase, clear cache, update composer dependencies and reinstall Magento.
Go to 'vagrant-magento' created earlier and run in command line:

```
bash m-switch-to-ce
OR
bash m-switch-to-ee
```

Force switch can be done using `-f` flag even if already switched to the target edition. May be helpful to relink EE modules after switching between branches.

Upgrade can be performed instead of re-installation using `-u` flag.

:information_source: On Windows hosts (or when NFS mode is disabled in [config.yaml](etc/config.yaml.dist) explicitly) you will be asked to wait until code is uploaded to guest machine by PhpStorm (PhpStorm must be launched). To continue the process press any key.

### Sample data installation

Make sure that `ce_sample_data` and `ee_sample_data` are defined in [config.yaml](etc/config.yaml.dist) and point CE and optionally EE sample data repositories.
During initial project setup or during `bash init_project.sh -fc` (with `-fc` project will be re-created from scratch), sample data repositories willl be checked out to `vagrant_project_root/magento2ce/magento2ce-sample-data` and `vagrant_project_root/magento2ce/magento2ee-sample-data`.

To install Magento with sample data set `install_sample_data` in [config.yaml](etc/config.yaml.dist) to `1` and run `bash m-switch-to-ce -f` or `bash m-switch-to-ee -f`, depending on the edition to be installed. To disable sample data, set this option to `0` and force-switch to necessary edition (using the same commands).

### Use Magento CLI (bin/magento)

Go to 'vagrant-magento' created earlier and run in command line:

```
bash m-bin-magento <command_name>
e.g.
bash m-bin-magento list
```

### Debugging with XDebug

XDebug is already configured to connect to the host machine automatically. So just:

 1. Set XDEBUG_SESSION=1 cookie (e.g. using 'easy Xdebug' extension for Firefox). See [XDebug documentation](http://xdebug.org/docs/remote) for more details
 1. Start listening for PHP Debug connections in PhpStorm on default 9000 port. See how to [integrate XDebug with PhpStorm](https://www.jetbrains.com/phpstorm/help/configuring-xdebug.html#integrationWithProduct)
 1. Set beakpoint or set option in PhpStorm menu 'Run -> Break at first line in PHP scripts'

To debug a CLI script:

 1. Create [remote debug configuration](https://www.jetbrains.com/help/phpstorm/2016.1/run-debug-configuration-php-remote-debug.html) in PhpStorm, use `phpstorm` as IDE key
 1. Run created remote debug configuration
 1. Run CLI command on the guest as follows (`xdebug.remote_host` value might be different for you):

 ```
 php -d xdebug.remote_autostart=1 <path_to_cli_script>
 ```

To debug Magento Setup script, go to [Magento installation script](scripts/guest/m-reinstall) and find `php ${install_cmd}`. Follow steps above for any CLI script

:information_source: In addition to XDebug support, [config.yaml](etc/config.yaml.dist) has several options in `debug` section which allow storefront and admin UI debugging. Plus, desired Magento mode (developer/production/default) can be enabled using `magento_mode` option, default is developer mode.

### Connecting to MySQL DB

Answer can be found [here](https://github.com/paliarush/magento2-vagrant-for-developers/issues/8)

### View emails sent by Magento

All emails are saved to 'vagrant-magento/log/email' in HTML format.

### Accessing PHP and other config files

It is possible to view/modify majority of guest machine config files directly from IDE on the host. They will be accessible in [etc/guest](etc/guest) directory only when guest machine is running. The list of accessible configs includes: PHP, Apache, Mysql, Varnish, RabbitMQ.
Do not edit any symlinks using PhpStorm because it may break your installation.

After editing configs in IDE it is still required to restart related services manually.

### Upgrading Magento

Sometimes it is necessary to test upgrade flow. This can be easily done as follows (assuming that you have installed instance):

 - For git-based installation - check out codebase corresponding to the target Magento version. Or modify your `composer.json` in case of composer-based installation
 - Use commands described in [Switch between CE and EE](#switch-between-ce-and-ee) section with `-u` flag

### Multiple Magento instances

To install several Magento instances based on different code bases, just follow [Installation steps](#installation-steps) to initialize project in another directory on the host.
Unique IP address, SSH port and domain name will be generated for each new instance if not specified manually in `etc/config.yaml`

### Update Composer dependencies

Go to 'vagrant-magento' created earlier and run in command line:

```
bash m-composer install
OR
bash m-composer update
```

## Environment configuration

### Switch between PHP 5.6 and 7.0

Set "use_php7: 1" for PHP7 and "use_php7: 0" for PHP5.6 in [config.yaml](etc/config.yaml.dist).
PHP version will be applied after "vagrant reload".

### Activating Varnish

Set `use_varnish: 1` to use varnish along apache in [config.yaml](etc/config.yaml.dist). Changes will be applied on `m-reinstall`.
It will use default file etc/magento2_default_varnish.vcl.dist generated from a Magento instance.
Varnish Version: 3.0.5

Use the following commands to enable/disable varnish without reinstalling Magento: `m-varnish disable` or `m-varnish enable`.

### Activating ElasticSearch

:information_source: Available in Magento EE only.

Set `search_engine: "elasticsearch"` in [config.yaml](etc/config.yaml.dist) to use ElasticSearch as current search engine or `search_engine: "mysql"` to use MySQL. Changes will be applied on `m-reinstall`.

Use the following commands to switch between search engines without reinstalling Magento: `m-search-engine elasticsearch` or `m-search-engine mysql`.

### Redis for caching

:information_source: Available in Magento v2.0.6 and higher.

Redis is configured as cache backend by default. It is still possible to switch back to filesystem cache by changing `environment_cache_backend` to `filesystem` in [config.yaml](etc/config.yaml.dist).

### Reset environment

It is possible to reset project environment to default state, which you usually get just after project initialization. The following command will delete vagrant box and vagrant project settings. After that it will initialize project from scratch. Magento 2 code base (`magento2ce` directory) and [etc/config.yaml](etc/config.yaml.dist) and PhpStorm settings will stay untouched, but guest config files (located in [etc/guest](etc/guest)) will be cleared.

Go to 'vagrant-magento' created earlier and run in command line:

```
bash init_project.sh -f
```

It is possible to reset Magento 2 code base at the same time. Magento 2 code base will be deleted and then cloned from the repositories specified in [etc/config.yaml](etc/config.yaml.dist)

```
bash init_project.sh -fc
```

To reset PhpStorm project configuration, in addition to `-f` specify `-p` option:

```
bash init_project.sh -fp
```

Ultimate project reset can be achieved by combining all available flags:

```
bash init_project.sh -fcp
```

### FAQ

 1. To debug any CLI script in current Vagrant project, set `debug:vagrant_project` option in [config.yaml](etc/config.yaml.dist) to `1`
 1. Is Windows 10 supported? Yes, but you may face the same issue as described [here](https://github.com/paliarush/magento2-vagrant-for-developers/issues/36). Also Virtual box may not work on Windows 10 in headless mode, see how to [enable GUI mode](https://www.vagrantup.com/docs/virtualbox/configuration.html)
 1. ![](docs/images/linux-icon.png)![](docs/images/osx-icon.png) On OSX and \*nix hosts NFS will be used by default to sync your project files with guest. On some hosts Vagrant cannot configure NFS properly, in this case it is possible to deploy project without NFS by setting `use_nfs` option in [config.yaml](etc/config.yaml.dist) to `0` <br />
 1. ![](docs/images/windows-icon.png) On Windows hosts you might face `Composer Install Error: ZipArchive::extractTo(): Full extraction path exceed MAXPATHLEN (260)` exception during `composer install`. This can be fixed in 2 ways: decrease path length to the project directory or set `composer_prefer_source` option in [config.yaml](etc/config.yaml.dist) to `1`
 1. Make sure that you used `vagrant-magento` directory as project root in PHP Storm (not `vagrant-magento/magento2ce`)
 1. If project opened in PhpStorm looks broken, close PhpStorm  and remove `vagrant-magento/.idea`. After opening project in PhpStorm again everything should look good
 1. If code is not synchronized properly on Windows hosts (or when NFS mode is disabled in [config.yaml](etc/config.yaml.dist) explicitly), make sure that PhpStorm is running before making any changes in the code. This is important because otherwise PhpStorm will not be able to detect changes and upload them to the guest machine
 1. Please make sure that currently installed software, specified in [requirements section](#requirements), meets minimum version requirement
 1. If MySQL fails to start and Magento reinstallation fails with `ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (13)`, try to run login to virtual machine using `vagrant ssh` and then run `sudo dpkg-reconfigure mysql-server-5.6`, then `sudo service mysql restart.`
 1. Be careful if your OS is case-insensitive, NFS might break the symlinks if you cd into the wrong casing and you power the vagrant up. Just be sure to cd in to the casing the directory was originally created as.
