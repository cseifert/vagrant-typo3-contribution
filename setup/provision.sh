sudo apt-get update && sudo apt-get -y upgrade

# load German locale
sudo locale-gen de_DE.UTF-8

# install required software
export DEBIAN_FRONTEND=noninteractive

sudo apt-get install -q -y --force-yes ack-grep
sudo apt-get install -q -y --force-yes graphicsmagick
sudo apt-get install -q -y --force-yes make
sudo apt-get install -q -y --force-yes curl
sudo apt-get install -q -y --force-yes dos2unix
sudo apt-get install -q -y --force-yes tofrodos
sudo apt-get install -q -y --force-yes unzip
sudo apt-get install -q -y --force-yes git

### PHP
sudo apt-get install -q -y --force-yes php5-cli
sudo apt-get install -q -y --force-yes php5-fpm
sudo apt-get install -q -y --force-yes php5-mysql
sudo apt-get install -q -y --force-yes php5-curl
sudo apt-get install -q -y --force-yes php5-gd
sudo apt-get install -q -y --force-yes php5-gmp
sudo apt-get install -q -y --force-yes php5-mcrypt
sudo apt-get install -q -y --force-yes php5-intl

sudo sed -i "s/listen =.*/listen = /var/run/php5-fpm.sock/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/;listen.allowed_clients/listen.allowed_clients/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/user = www-data/user = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/group = www-data/group = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/listen\.mode.*/listen.mode = 0666/" /etc/php5/fpm/pool.d/www.conf

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 256M/" /etc/php5/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 2G/" /etc/php5/fpm/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = 2G/" /etc/php5/fpm/php.ini
sudo sed -i "s/max_execution_time = .*/max_execution_time = 240/" /etc/php5/fpm/php.ini
sudo sed -i "s/; max_input_vars = .*/max_input_vars = 1500/" /etc/php5/fpm/php.ini

sudo service php5-fpm restart

### MariaDB
debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password password root"
debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password_again password root"

apt-get install -y --allow-unauthenticated mariadb-server mariadb-client

sudo sed -i "s/skip-external-locking/# skip-external-locking/g" /etc/mysql/my.cnf
sudo sed -i "s/bind-address/# bind-address/g" /etc/mysql/my.cnf

sudo service mysql restart
mysql -u root -proot -e"use mysql; update user set host='%' where user='root' and host='localhost';"

### Nginx ###
sudo apt-get install -q -y --force-yes nginx
sudo sed -i "s/user www-data/user vagrant/" /etc/nginx/nginx.conf
sudo mv /tmp/typo3.conf /etc/nginx/sites-available/typo3.conf 
sudo sed -i "s/SERVER_NAME_MARKER/$2/" /etc/nginx/sites-available/typo3.conf 
sudo ln -s /etc/nginx/sites-available/typo3.conf /etc/nginx/sites-enabled/typo3.conf
sudo rm /etc/nginx/sites-enabled/default

sudo service nginx restart

### Composer ###
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/bin/composer
export HTTPS_PROXY_REQUEST_FULLURI=false
export HTTP_PROXY_REQUEST_FULLURI=true

### PhpMyAdmin ###
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password root"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password root"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password root"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

### Mailcatcher ###
sudo apt-get install -q -y --force-yes build-essential software-properties-common libsqlite3-dev ruby1.9.1-dev
sudo gem install mailcatcher
sudo mailcatcher --ip $1

### NPM, Bower, Grunt
sudo apt-get install -q -y --force-yes npm
sudo npm install bower grunt grunt-cli -g

### GIT setup ###
cd /var/www
sudo git clone --recursive git://git.typo3.org/Packages/TYPO3.CMS.git TYPO3.CMS
cd TYPO3.CMS
git config --global url."ssh://$3@review.typo3.org:29418".pushInsteadOf git://git.typo3.org
git config remote.origin.push HEAD:refs/for/master
curl -o .git/hooks/commit-msg "https://typo3.org/fileadmin/resources/git/commit-msg.txt" && chmod +x .git/hooks/commit-msg
git config user.name "$4"
git config user.email "$5"
sudo composer install
touch FIRST_INSTALL