#!/usr/bin/env bash

# Add shortcuts to enable support for other boxes
INSTALL="yum install -y"
REMOVE="yum remove -y"
UPDATE="yum update -y"

##@@APACHE
echo "Installing Apache"
$INSTALL httpd

##@@MARIA
cat >>  /etc/yum.repos.d/mariadb.repo << EOF
# MariaDB 10.0 CentOS repository list - created 2015-02-25 20:59 UTC
# http://mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.0/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
yum install -y mariadb-server
systemctl start mysql.service


mysql -u root <<-EOF
UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PW') WHERE User='root';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
EOF

##@@EPEL
# Extra repos supporting newest PHP version and modules (64 bit version).
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
##@@REMI
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

cat > /etc/yum.repos.d/remi.repo <<EOF
[remi]
name=Remi's RPM repository for Enterprise Linux 7 - $basearch
mirrorlist=http://rpms.remirepo.net/enterprise/7/remi/mirror
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi


[remi-php56]
name=Remi's PHP 5.6 RPM repository for Enterprise Linux 7 - $basearch
mirrorlist=http://rpms.remirepo.net/enterprise/7/php56/mirror
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi
EOF

##@@YUM UPDATE
$UPDATE
apachectl restart

##@@MYSQL
rpm -ivh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm

##@@PHP
$INSTALL php
$INSTALL install php-mysqlnd
$INSTALL install php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap curl curl-devel php-mcrypt
apachectl restart

##@@TOOLS
echo "Installing git"
$INSTALL curl git
echo "Installing mercurial"
$INSTALL mercurial

##@@EDITOR
echo "Installing Editors"
$INSTALL vim
$INSTALL mc

##@@COMPOSERvagrant
echo "Installing Composer"
curl -sS https://getcomposer.org/installer | php
echo "Moving Composer"
mv composer.phar /usr/local/bin/composer~

##@@SSH-Keygen
# Start the SSH-Agent
eval $(ssh-agent)

# Generate SSH Key
cd .ssh
ssh-keygen -f id_rsa -t rsa -N ''

chmod 755 /home/vagrant/.ssh/id_rsa.pub

# Add the key to the agent
ssh-add /home/vagrant/.ssh/id_rsa

chmod 755 /home/vagrant

##@@PROJECT
ROOT=/home/vagrant/sync

DATA="<VirtualHost *:80>
        ServerName localhost
		ServerAlias localhost
		
		SetEnv OTAP O
		EnableSendfile off
		
        DocumentRoot $ROOT
        
        ## Everything to see here. Just the log files.  Good to use for troubleshooting errors.
        CustomLog /var/log/httpd/localhost-access.log combined
        ErrorLog /var/log/httpd/localhost-error.log
        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
</VirtualHost>"

echo "$DATA" > /etc/httpd/conf.d/001-localhost.conf && apachectl restart 

VHOSTS="
NameVirtualHost *:80
<Directory $ROOT>
	Options Indexes FollowSymLinks MultiViews
    DirectoryIndex index.php index.html index.htm
	AllowOverride All

	Require all granted
</Directory>

<VirtualHost *:80>
	ServerName level4.localhost
    ServerAlias *.*.*.*.localhost

    VirtualDocumentRoot $ROOT/%4/%3/%2/%1
    SetEnv OTAP O
	EnableSendfile off
</VirtualHost>
<VirtualHost *:80>
	ServerName level3.localhost
    ServerAlias *.*.*.localhost

    VirtualDocumentRoot $ROOT/%3/%2/%1
    SetEnv OTAP O
	EnableSendfile off
</VirtualHost>
<VirtualHost *:80>
	ServerName level2.localhost
    ServerAlias *.*.localhost

    VirtualDocumentRoot $ROOT/%2/%1
    SetEnv OTAP O
	EnableSendfile off
</VirtualHost>
<VirtualHost *:80>
	ServerName level1.localhost
    ServerAlias *.localhost

    VirtualDocumentRoot $ROOT/%1
    SetEnv OTAP O
	EnableSendfile off
</VirtualHost>
"

echo "$VHOSTS" > /etc/httpd/conf.d/002-vhosts.conf && apachectl restart

$REMOVE selinux*
apachectl restart