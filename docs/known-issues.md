Known issues
----------------------------

1. PHP Warning:  require(/var/www/magento2ce/app/etc/NonComposerComponentRegistration.php): failed to open stream: No such file or directory
   Check modified files from /var/www/magento2ce/app/etc/ in git and revert them.

2. Guest system behaves wierd, e.g. install process can be suddenly killed.
   Try to increase memory for guest machine.


