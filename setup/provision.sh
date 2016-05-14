add-apt-repository -y ppa:ondrej/php
apt-add-repository -y ppa:brightbox/ruby-ng
apt-get update && apt-get -y upgrade

# load German locale
locale-gen de_DE.UTF-8

# install required software
export DEBIAN_FRONTEND=noninteractive

apt-get install -q -y --force-yes ack-grep
apt-get install -q -y --force-yes graphicsmagick
apt-get install -q -y --force-yes make
apt-get install -q -y --force-yes curl
apt-get install -q -y --force-yes dos2unix
apt-get install -q -y --force-yes tofrodos
apt-get install -q -y --force-yes unzip
apt-get install -q -y --force-yes git

### PHP
apt-get install -q -y --force-yes php7.0
apt-get install -q -y --force-yes php7.0-cli
apt-get install -q -y --force-yes php7.0-fpm
apt-get install -q -y --force-yes php7.0-mysql
apt-get install -q -y --force-yes php7.0-curl
apt-get install -q -y --force-yes php7.0-gd
apt-get install -q -y --force-yes php7.0-gmp
apt-get install -q -y --force-yes php7.0-mcrypt
apt-get install -q -y --force-yes php7.0-intl
apt-get install -q -y --force-yes php7.0-xdebug
apt-get install -q -y --force-yes php7.0-mbstring
apt-get install -q -y --force-yes php7.0-xml
apt-get install -q -y --force-yes php7.0-soap
apt-get install -q -y --force-yes php7.0-zip
apt-get install -q -y --force-yes php7.0-bz2

sed -i "s/listen =.*/listen = /var/run/php/php7.0-fpm.sock/" /etc/php/7.0/fpm/pool.d/www.conf
sed -i "s/;listen.allowed_clients/listen.allowed_clients/" /etc/php/7.0/fpm/pool.d/www.conf
sed -i "s/user = www-data/user = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
sed -i "s/listen\.mode.*/listen.mode = 0666/" /etc/php/7.0/fpm/pool.d/www.conf

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 256M/" /etc/php/7.0/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 2G/" /etc/php/7.0/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 2G/" /etc/php/7.0/fpm/php.ini
sed -i "s/max_execution_time = .*/max_execution_time = 240/" /etc/php/7.0/fpm/php.ini
sed -i "s/; max_input_vars = .*/max_input_vars = 1500/" /etc/php/7.0/fpm/php.ini

chown vagrant /etc/php/7.0/mods-available/xdebug.ini
chgrp vagrant /etc/php/7.0/mods-available/xdebug.ini
cat << EOF >> /etc/php/7.0/mods-available/xdebug.ini
xdebug.remote_enable = on
xdebug.remote_host=10.0.2.2
xdebug.remote_autostart = 1
xdebug.remote_log="/var/log/xdebug/remote.log"
xdebug.profiler_output_dir="/var/log/xdebug"
xdebug.trace_output_dir="/var/log/xdebug"
xdebug.max_nesting_level=400
EOF

service php7.0-fpm restart

### MariaDB
debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password password root"
debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password_again password root"

apt-get install -y --allow-unauthenticated mariadb-server mariadb-client

sed -i "s/skip-external-locking/# skip-external-locking/g" /etc/mysql/my.cnf
sed -i "s/bind-address/# bind-address/g" /etc/mysql/my.cnf

service mysql restart
mysql -u root -proot -e"use mysql; update user set host='%' where user='root' and host='localhost';"

### Nginx ###
apt-get install -q -y --force-yes nginx
sed -i "s/user www-data/user vagrant/" /etc/nginx/nginx.conf
mv /tmp/typo3.conf /etc/nginx/sites-available/typo3.conf 
sed -i "s/SERVER_NAME_MARKER/$2/" /etc/nginx/sites-available/typo3.conf 
ln -s /etc/nginx/sites-available/typo3.conf /etc/nginx/sites-enabled/typo3.conf
rm /etc/nginx/sites-enabled/default

service nginx restart

### Composer ###
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/bin/composer

### PhpMyAdmin ###
cd /usr/share
wget https://files.phpmyadmin.net/phpMyAdmin/4.6.0/phpMyAdmin-4.6.0-all-languages.zip
unzip phpMyAdmin-4.6.0-all-languages.zip
mv phpMyAdmin-4.6.0-all-languages phpmyadmin
chmod -R 0755 phpmyadmin

### Mailcatcher ###
apt-get install -q -y --force-yes build-essential software-properties-common libsqlite3-dev ruby2.2 ruby2.2-dev
gem install mailcatcher
mailcatcher --ip 0.0.0.0

### NPM, Bower, Grunt
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
apt-get install -q -y --force-yes nodejs
npm install bower grunt grunt-cli -g

### GIT setup ###
mv /tmp/ssh_config.conf /home/vagrant/.ssh/config
sed -i "s/USERNAME/$3/" /home/vagrant/.ssh/config
chmod 600 ~/.ssh/id_rsa*
chmod 600 ~/.ssh/authorized_keys
cd /var/www
git clone --recursive git://git.typo3.org/Packages/TYPO3.CMS.git TYPO3.CMS
cd TYPO3.CMS
git config --global url."ssh://$3@review.typo3.org:29418".pushInsteadOf git://git.typo3.org
git config remote.origin.push HEAD:refs/for/master
curl -o .git/hooks/commit-msg "https://typo3.org/fileadmin/resources/git/commit-msg.txt" && chmod +x .git/hooks/commit-msg
git config user.name "$4"
git config user.email "$5"

### TYPO3 setup ###
composer install
touch FIRST_INSTALL