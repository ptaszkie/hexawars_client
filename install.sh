#!/bin/bash

###########################################################
# REPOS
###########################################################

sudo touch /var/www/install_log.txt  &>>/var/www/install_log.txt
sudo chown &(whoami):&(whoami) /var/www/install_log.txt  &>>/var/www/install_log.txt

echo "=== Dodawanie repozytoriow ==="

# mongodb
echo "- mongodb"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 &>/var/www/install_log.txt
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list &>>/var/www/install_log.txt

# php
echo "- php"
sudo add-apt-repository -y ppa:ondrej/php &>>/var/www/install_log.txt

# nginx
echo "- nginx"
sudo add-apt-repository -y ppa:nginx/stable &>>/var/www/install_log.txt

echo "- update repozytoriow"
sudo apt-get update &>>/var/www/install_log.txt

###########################################################
# MONGODB
###########################################################

echo ""
echo "=== Instalacja MongoDB ==="
echo "- installacja"
sudo apt-get install -y mongodb-org &>>/var/www/install_log.txt
echo "- start serwisu"
sudo systemctl enable mongod.service &>>/var/www/install_log.txt
sudo systemctl start mongod.service &>>/var/www/install_log.txt

###########################################################
# NGINX & PHP7.1
###########################################################
echo ""
echo "=== Instalacja PHP7.1 ==="
echo "- instalacja"
sudo apt-get install -y php7.1-fpm php7.1-mbstring php7.1-mcrypt php7.1-xml php7.1-zip php7.1-dev &>>/var/www/install_log.txt

echo "- poprawka cgi.fix_patchinfo"
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.1/fpm/php.ini &>>/var/www/install_log.txt

###########################################################
# MONGODB C DRIVER
###########################################################
echo ""
echo "=== Instalacja MongoDB C Driver ==="
echo "- pobieranie plikow"
cd ~
git clone https://github.com/mongodb/mongo-c-driver.git &>>/var/www/install_log.txt
cd mongo-c-driver
git checkout 1.4.0 &>>/var/www/install_log.txt
echo "- generowanie plikow do kompilacji"
./autogen.sh --with-libbson=bundled &>>/var/www/install_log.txt
echo "- kompilacja"
sudo make &>>/var/www/install_log.txt && \
echo "- instalacja" && \
sudo make install &>>/var/www/install_log.txt
echo "- sprzatanie"
cd ~ 
sudo rm -rf mongo-c-driver/ &>>/var/www/install_log.txt


###########################################################
# MONGODB C++ DRIVER
###########################################################
echo ""
echo "=== Instalacja MongoDB C++ Driver ==="

echo "- instalacja cmake"
cd ~
sudo apt-get install -y cmake &>>/var/www/install_log.txt
echo "- pobieranie plikow"
git clone https://github.com/mongodb/mongo-cxx-driver.git &>>/var/www/install_log.txt
cd mongo-cxx-driver/
git checkout r3.0.1 &>>/var/www/install_log.txt
cd build/
echo "- generowanie plikow do kompilacji"
cmake -DCMAKE_BUILD_TYPE=Release -DLIBMONGOC_DIR=/usr/local -DCMAKE_INSTALL_PREFIX=/usr/local .. &>>/var/www/install_log.txt
echo "- kompilacja"
sudo make &>>/var/www/install_log.txt && \
echo "- instalacja" && \
sudo make install &>>/var/www/install_log.txt
echo "- sprzatanie"
cd ~
sudo rm -rf mongo-cxx-driver/ &>>/var/www/install_log.txt

###########################################################
# MONGODB PHP DRIVER
###########################################################
echo ""
echo "=== Instalacja PHP7 MongoDB Driver ==="

echo "- instalacja"
sudo pecl channel-update pecl.php.net &>>/var/www/install_log.txt
sudo pecl install mongodb &>>/var/www/install_log.txt

echo "- aktualizacja konfiguracji php"
sudo sed -i '$ a extension=mongodb.so' /etc/php/7.1/fpm/php.ini &>>/var/www/install_log.txt
sudo sed -i '$ a extension=mongodb.so' /etc/php/7.1/cli/php.ini &>>/var/www/install_log.txt

echo "- restart serwisu php"
sudo service php7.1-fpm restart &>>/var/www/install_log.txt

###########################################################
# NGINX
###########################################################
echo ""
echo "=== Instalacja serwera nginx ==="

echo "- instalacja"
sudo apt-get install -y nginx &>>/var/www/install_log.txt

echo "- nadanie praw folderom i plikom"
sudo chown -R www-data:www-data /var/www  &>>/var/www/install_log.txt
sudo chmod -R 775 /var/www  &>>/var/www/install_log.txt
cd /var/www
sudo find ./ -type f -exec chmod 664 {} \;

echo "- instalacja ustawien serwera"
echo "" > hexawars
sudo sed -i 'a \
server { \
    listen 80; \
    listen [::]:80 ipv6only=on; \
 \
    root /var/www/hexawars_client/public; \
    index index.php index.html index.htm; \
    server_name hexawars.pl; \
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

echo "- dodanie wpisu do /etc/hosts"
sudo sed -i '$ a 127.0.0.1 hexawars.pl' /etc/php/7.1/cli/php.ini &>>/var/www/install_log.txt


sudo mv hexawars /etc/nginx/sites-available/ &>>/var/www/install_log.txt
sudo ln -s /etc/nginx/sites-available/hexawars /etc/nginx/sites-enabled/hexawars &>>/var/www/install_log.txt
sudo rm -rf /etc/nginx/sites-enabled/default &>>/var/www/install_log.txt

echo "- przeladowanie serwisu nginx"
sudo service nginx restart &>>/var/www/install_log.txt


###########################################################
# COMPOSER & LARAVEL
###########################################################

echo ""
echo "=== Finalizacja ==="

echo "- instalacja Composer"
cd ~
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" &>>/var/www/install_log.txt
echo "- instalacja"
sudo mkdir bin &>>/var/www/install_log.txt
sudo php composer-setup.php --install-dir=bin --filename=composer &>>/var/www/install_log.txt
rm -rf composer-setup.php &>>/var/www/install_log.txt

echo "- instalacja paczek dla laravel"
cd /var/www/hexawars_client &>>/var/www/install_log.txt
composer install &>>/var/www/install_log.txt

echo "- generowanie klucza"
php artisan key:generate &>>/var/www/install_log.txt

echo ""
echo "==============================================================="
echo "Klient gry dostepny pod adresem http://hexawars.pl."
echo "Przed wejsciem na strone nalezy uruchomic serwer gry."
echo "==============================================================="s
