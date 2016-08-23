#!/bin/bash

###########################################################
# MONGODB
###########################################################

# dodać linijke do /etc/hosts
#127.0.0.1 hexawars.pl

# dodanie repozytorium
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# instalacja
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl enable mongod.service
sudo systemctl start mongod.service

###########################################################
# NGINX & PHP7.1
###########################################################

# dodanie repo php
sudo add-apt-repository -y ppa:ondrej/php

# instalacja php7.1 fastcgi i dodatkow potrzebnych Laravel
sudo apt-get update
sudo apt-get install -y php7.1-fpm php7.1-mbstring php7.1-mcrypt php7.1-xml php7.1-zip php7.1-dev

###########################################################
# MONGODB PHP DRIVER
###########################################################

sudo pecl channel-update pecl.php.net
sudo pecl install mongodb

# dodac: extension=mongodb.so
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.1/fpm/php.ini
sudo sed -i '$ a extension=mongodb.so' /etc/php/7.1/fpm/php.ini
sudo sed -i '$ a extension=mongodb.so' /etc/php/7.1/cli/php.ini

sudo service php7.1-fpm restart

###########################################################
# NGINX
###########################################################

sudo add-apt-repository -y ppa:nginx/stable
sudo apt-get update
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

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo makdir bin
sudo php composer-setup.php --install-dir=bin --filename=composer

# instalacja providerow dla Laravel
composer install

# nadanie wymaganych uprawnien
sudo chmod -R 775 storage/

# optymalizacja Laravel
php artisan migrate
php artisan optimize




