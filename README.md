# Vagrant for Magento, optimized for Windows hosts

## What You get

The current Vagrant configuration aims to solve performance issues of Magento installed on Virtual Box, when the host is Windows. 
See [explanation of the proposed solution](docs/performance-issue-on-windows-hosts.md).

With current configuration Vagrant will:

 1. Run Ubuntu box
 1. Install and configure all software necessary for Magento 2
 1. Install all necessary libraries
 1. Install the Magento 2 application

## Environment set up workflow

If you never used Vagrant before, read [Vagrant Docs](https://docs.vagrantup.com/v2/)

### Prerequisites
- [Vagrant](https://www.vagrantup.com/downloads.html) is installed and available globally in command line
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Composer](https://getcomposer.org/doc/00-intro.md) is installed and is available globally in command line
- Make sure you have SSH keys generated and associated with your github account, see [manual](https://help.github.com/articles/generating-ssh-keys/).
:information_source: You can use another way of getting codebase instead of cloning, it does not matter for successful installation.

### To install the whole image from scratch

 1. Run in command line from the directory which contains your projects:
     1. Prepare Magento codebase. This step is optional, just ensure you have 'magento2ce' directory with Magento code available.
         
         :information_source: To have 'composer install' here work faster, remove 'prefer-source' option and follow the instructions provided in [Gighub limitations section](README.md#github-limitations)
     
        ```
        git clone git@github.com:magento/magento2.git magento2ce
        cd magento2ce
        mkdir -p var/generation
        composer install --prefer-source
        cd ..
        ```
    
     1. Download project with Vagrant configuration and install Magento (~ 5 minutes):
     
        ```
        git clone git@github.com:paliarush/vagrant-magento.git vagrant-magento
        cd vagrant-magento
        vagrant up
        ```
 1. Add corresponding record to your `hosts` file on the host machine:
 
    ```
    192.168.10.11 magento2.vagrant
    ```
 1. After the installation is complete, [set up synchronization with PHP Storm](docs/phpstorm-configuration.md)

### After installation

Upon a successful installation, you'll see the location and URL of the newly-installed Magento 2 application in console.
See a list of [default credentials and settings](README.md#default-credentials).

### Default credentials and settings

Web access:
- Access storefront at `http://magento2.vagrant`
- Access admin panel at `http://magento2.vagrant/admin/`
- Magento admin user/password: `admin/123123q`

Codebase and DB access:
- Path to your Magento installation on the VM: `/var/www/magento2ce`
- MySQL DB host: `localhost` (not accessible remotely)
- MySQL DB name: `magento`, `magento_integration_tests`
- MySQL DB user/password: just use `mysql` with no user and password (`root/password` will be used by default)

### GitHub Limitations

Be aware that you may encounter GitHub limits on the number of downloads (used by Composer to download Magento dependencies).

These limits may significantly slow down the installation since all of the libraries will be cloned from GitHub repositories instead of downloaded as ZIP archives. In the worst case, these limitations may even terminate the installation.

If you have a GitHub account, you can bypass these limitations by using an OAuth token in the Composer configuration. See [API rate limit and OAuth tokens](https://getcomposer.org/doc/articles/troubleshooting.md#api-rate-limit-and-oauth-tokens) for more information.

For the Vagrant configuration you may specify your token in `local.config/github.oauth.token` file after cloning the repository. The file is a basic text file and is ignored by Git, so you'll need to create it yourself. Simply write your OAuth token in this file making sure to avoid any empty spaces, and it will be read during deployment. You should see the following message in the Vagrant log:
```
Installing GitHub OAuth token from /vagrant/local.config/github.oauth.token
```

## Magento development workflow
    
### Reinstall Magento
To save some time and get clear Magento installation, you can skip installation of software like web server or php.
The following command will clear Magento DB, Magento caches and reinstall Magento instance.

Go to 'vagrant-magento' created earlier and run in command line:

```
vagrant provision --provision-with install_magento
```

### Clear magento cache

Go to 'vagrant-magento' created earlier and run in command line:

```
vagrant ssh -c 'magento_clear_cache'
```

### Debugging with XDebug

XDebug is already configured to connect to the host machine automatically. So just:
 
 1. Set XDEBUG_SESSION=1 cookie (e.g. using 'easy Xdebug' extension for Firefox). See [XDebug documentation](http://xdebug.org/docs/remote) for more details
 1. Start listening for PHP Debug connections in PhpStorm. See how to [integrate XDebug with PhpStorm](https://www.jetbrains.com/phpstorm/help/configuring-xdebug.html#integrationWithProduct)
 1. Set beakpoint or set option in PhpStorm menu 'Run -> Break at first line in PHP scripts'

## Related Repositories

- https://github.com/buskamuza/magento2-product-vagrant
