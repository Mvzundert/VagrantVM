# VagrantVM

OS: Centos 7

<b>Provisioning:</b>
<br>
Bootstrap contains:
<br>
- Apache
- PHP 5.6
- mysql
- Git
- Mercurial
- Composer
- SSH keygeneration when provisioning
- Wildcard virtual hosts.
- SELinux is removed (localhost only!)

Available editors
<br>
- Vim
- mcedit
- nano

<b>Specific provisioning files</b>
<br>
Uncomment these in the vargrant file to activate.<br>

- Drush (for drupal development)
- Node (grunt, gulp,bower)
- Beanstalkd (http://kr.github.io/beanstalkd/)
-