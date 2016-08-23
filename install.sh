#!/bin/bash

###########################################################
# REPOS
###########################################################

# dodać linijke do /etc/hosts
#127.0.0.1 hexawars.pl

echo "Dodawanie repozytoriów\n"

# dodanie repo mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# dodanie repo php
sudo add-apt-repository -y ppa:ondrej/php

# nginx
sudo add-apt-repository -y ppa:nginx/stable

sudo apt-get update

###########################################################
# MONGODB
###########################################################

echo "Instalacja MongoDB\n"

sudo apt-get install -y mongodb-org
sudo systemctl enable mongod.service
sudo systemctl start mongod.service

###########################################################
# NGINX & PHP7.1
###########################################################

echo "Instalacja PHP7.1\n"

sudo apt-get install -y php7.1-fpm php7.1-mbstring php7.1-mcrypt php7.1-xml php7.1-zip php7.1-dev

# dodac: extension=mongodb.so
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.1/fpm/php.ini

###########################################################
# MONGODB C DRIVER
###########################################################

echo "Instalacja C MongoDB Driver\n"

git clone https://github.com/mongodb/mongo-c-driver.git
cd mongo-c-driver
git checkout 1.4.0
./autogen.sh --with-libbson=bundled
sudo make && sudo make install
cd ~

###########################################################
# MONGODB C++ DRIVER
###########################################################

echo "Instalacja C++ MongoDB Driver\n"

sudo apt-get install -y cmake
git clone https://github.com/mongodb/mongo-cxx-driver.git
cd mongo-cxx-driver/
git checkout r3.0.1
cd build/
cmake -DCMAKE_BUILD_TYPE=Release -DLIBMONGOC_DIR=/usr/local -DCMAKE_INSTALL_PREFIX=/usr/local ..
sudo make && sudo make install
cd ~

###########################################################
# MONGODB PHP DRIVER
###########################################################

echo "Instalacja PHP7 MongoDB Driver\n"

sudo pecl channel-update pecl.php.net
sudo pecl install mongodb

sudo sed -i '$ a extension=mongodb.so' /etc/php/7.1/fpm/php.ini
sudo sed -i '$ a extension=mongodb.so' /etc/php/7.1/cli/php.ini

sudo service php7.1-fpm restart







###########################################################
# NGINX
###########################################################

echo "Instalacja nginx\n"

sudo apt-get install -y nginx

# configuracja
sudo chown -R www-data:www-data /var/www
sudo chmod -R 775 /var/www
sudo chmod -R g+s /var/www

echo "" > hexawars
sudo sed -i 'a \
server { \
    listen 80 default_server; \
    listen [::]:80 default_server ipv6only=on; \
 \
    root /var/www/hexawars_client/public; \
    index index.php index.html index.htm; \
 \
    location / { \
            try_files $uri $uri/ /index.php$is_args$args;\
    }\
\
    location ~ \\.php$ {\
	    try_files $uri /index.php =404;\
            fastcgi_split_path_info ^(.+\\.php)(/.+)$;\
            fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;\
            fastcgi_index index.php;\
	    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;\
            include fastcgi_params;\
    }\
}' hexawars

# przeniesienie pliku z ust. pod Laravel
sudo mv hexawars /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/hexawars /etc/nginx/sites-enabled/hexawars
sudo rm -rf /etc/nginx/sites-enabled/default

sudo service nginx restart


###########################################################
# COMPOSER & LARAVEL
###########################################################

echo "Instalacja composer\n"

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo mkdir bin
sudo php composer-setup.php --install-dir=bin --filename=composer



echo "Koniec."
