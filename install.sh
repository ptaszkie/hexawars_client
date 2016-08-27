#!/bin/bash

###########################################################
# REPOS
###########################################################

touch ../install_log.txt
chown $SUDO_USER:$SUDO_USER ../install_log.txt

printf "=== DODAWANIE REPOZYTORIOW ===\n\n" | tee -a /var/www/install_log.txt

# mongodb
echo "- mongodb" | tee -a /var/www/install_log.txt
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 &>/var/www/install_log.txt
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list &>>/var/www/install_log.txt

# php
echo "- php" | tee -a /var/www/install_log.txt
add-apt-repository -y ppa:ondrej/php &>>/var/www/install_log.txt

# nginx
echo "- nginx" | tee -a /var/www/install_log.txt
add-apt-repository -y ppa:nginx/stable &>>/var/www/install_log.txt

echo "- update repozytoriow" | tee -a /var/www/install_log.txt
apt-get update &>>/var/www/install_log.txt

###########################################################
# MONGODB
###########################################################

echo "" | tee -a /var/www/install_log.txt
echo "=== Instalacja MongoDB ===" | tee -a /var/www/install_log.txt

echo "- installacja" | tee -a /var/www/install_log.txt
apt-get install -y mongodb-org &>>/var/www/install_log.txt

echo "- start serwisu"  | tee -a /var/www/install_log.txt
systemctl enable mongod.service &>>/var/www/install_log.txt
systemctl start mongod.service &>>/var/www/install_log.txt

###########################################################
# NGINX & PHP7.1
###########################################################
echo "" | tee -a /var/www/install_log.txt
echo "=== Instalacja PHP7.1 ===" | tee -a /var/www/install_log.txt

echo "- instalacja" | tee -a /var/www/install_log.txt
apt-get install -y php7.1-fpm php7.1-mbstring php7.1-mcrypt php7.1-xml php7.1-zip php7.1-dev &>>/var/www/install_log.txt

echo "- poprawka cgi.fix_patchinfo" | tee -a /var/www/install_log.txt
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.1/fpm/php.ini &>>/var/www/install_log.txt

###########################################################
# MONGODB C DRIVER
###########################################################
echo "" | tee -a /var/www/install_log.txt
echo "=== Instalacja MongoDB C Driver ===" | tee -a /var/www/install_log.txt

echo "- pobieranie plikow" | tee -a /var/www/install_log.txt
cd ~
git clone https://github.com/mongodb/mongo-c-driver.git &>>/var/www/install_log.txt
cd mongo-c-driver
git checkout 1.4.0 &>>/var/www/install_log.txt

echo "- generowanie plikow do kompilacji"  | tee -a /var/www/install_log.txt
./autogen.sh --with-libbson=bundled &>>/var/www/install_log.txt

echo "- kompilacja" | tee -a /var/www/install_log.txt
make &>>/var/www/install_log.txt

echo "- instalacja" | tee -a /var/www/install_log.txt
make install &>>/var/www/install_log.txt

echo "- sprzatanie" | tee -a /var/www/install_log.txt
cd ~ 
rm -rf mongo-c-driver/ &>>/var/www/install_log.txt


###########################################################
# MONGODB C++ DRIVER
###########################################################
echo "" | tee -a /var/www/install_log.txt
echo "=== Instalacja MongoDB C++ Driver ===" | tee -a /var/www/install_log.txt

echo "- instalacja cmake" | tee -a /var/www/install_log.txt
cd ~
apt-get install -y cmake &>>/var/www/install_log.txt

echo "- pobieranie plikow" | tee -a /var/www/install_log.txt
git clone https://github.com/mongodb/mongo-cxx-driver.git &>>/var/www/install_log.txt
cd mongo-cxx-driver/
git checkout r3.0.1 &>>/var/www/install_log.txt
cd build/

echo "- generowanie plikow do kompilacji" | tee -a /var/www/install_log.txt
cmake -DCMAKE_BUILD_TYPE=Release -DLIBMONGOC_DIR=/usr/local -DCMAKE_INSTALL_PREFIX=/usr/local .. &>>/var/www/install_log.txt

echo "- kompilacja" | tee -a /var/www/install_log.txt
make &>>/var/www/install_log.txt

echo "- instalacja" | tee -a /var/www/install_log.txt
make install &>>/var/www/install_log.txt

echo "- sprzatanie" | tee -a /var/www/install_log.txt
cd ~
rm -rf mongo-cxx-driver/ &>>/var/www/install_log.txt

###########################################################
# MONGODB PHP DRIVER
###########################################################
echo "" | tee -a /var/www/install_log.txt
echo "=== Instalacja PHP7 MongoDB Driver ===" | tee -a /var/www/install_log.txt

echo "- instalacja" | tee -a /var/www/install_log.txt
pecl channel-update pecl.php.net &>>/var/www/install_log.txt
pecl install mongodb &>>/var/www/install_log.txt

echo "- aktualizacja konfiguracji php" | tee -a /var/www/install_log.txt
sed -i '$ a extension=mongodb.so' /etc/php/7.1/fpm/php.ini &>>/var/www/install_log.txt
sed -i '$ a extension=mongodb.so' /etc/php/7.1/cli/php.ini &>>/var/www/install_log.txt

echo "- restart serwisu php" | tee -a /var/www/install_log.txt
service php7.1-fpm restart &>>/var/www/install_log.txt

###########################################################
# NGINX
###########################################################
echo "" | tee -a /var/www/install_log.txt
echo "=== Instalacja serwera nginx ===" | tee -a /var/www/install_log.txt

echo "- instalacja" | tee -a /var/www/install_log.txt
apt-get install -y nginx &>>/var/www/install_log.txt

echo "- nadanie praw folderom i plikom" | tee -a /var/www/install_log.txt
chown -R www-data:www-data /var/www  &>>/var/www/install_log.txt
chmod -R 775 /var/www  &>>/var/www/install_log.txt
cd /var/www
find ./ -type f -exec chmod 664 {} \;

echo "- instalacja ustawien serwera" | tee -a /var/www/install_log.txt
echo "" > hexawars
sed -i 'a \
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

echo "- dodanie wpisu do /etc/hosts" | tee -a /var/www/install_log.txt
sed -i '$ a 127.0.0.1 hexawars.pl' /etc/hosts &>>/var/www/install_log.txt


mv hexawars /etc/nginx/sites-available/ &>>/var/www/install_log.txt
ln -s /etc/nginx/sites-available/hexawars /etc/nginx/sites-enabled/hexawars &>>/var/www/install_log.txt
rm -rf /etc/nginx/sites-enabled/default &>>/var/www/install_log.txt

echo "- przeladowanie serwisu nginx" | tee -a /var/www/install_log.txt
service nginx restart &>>/var/www/install_log.txt


###########################################################
# COMPOSER & LARAVEL
###########################################################

echo "" | tee -a /var/www/install_log.txt
echo "=== Finalizacja ===" | tee -a /var/www/install_log.txt

echo "- pobieranie Composer" | tee -a /var/www/install_log.txt
cd ~
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" &>>/var/www/install_log.txt
echo "- instalacja"
mkdir bin &>>/var/www/install_log.txt
php composer-setup.php --install-dir=bin --filename=composer &>>/var/www/install_log.txt
rm -rf composer-setup.php &>>/var/www/install_log.txt
chown $SUDO_USER:$SUDO_USER -R bin/ .pearrc .composer 

echo "- instalacja paczek dla laravel" | tee -a /var/www/install_log.txt
cd /var/www/hexawars_client
composer install &>>/var/www/install_log.txt

echo "- generowanie klucza" | tee -a /var/www/install_log.txt
cp .env.example .env &>>/var/www/install_log.txt
php artisan key:generate &>>/var/www/install_log.txt

echo "- naprawa praw plikow" | tee -a /var/www/install_log.txt
chown -R www-data:www-data /var/www  &>>/var/www/install_log.txt
chmod -R 775 /var/www  &>>/var/www/install_log.txt
cd /var/www
find ./ -type f -exec chmod 664 {} \;

echo ""
echo "==============================================================="
echo "Klient gry dostepny pod adresem http://hexawars.pl."
echo "Przed wejsciem na strone nalezy uruchomic serwer gry oraz"
echo "ustawic parametry polaczenia z baza danych w .env"
echo ""
echo "Log z instalacja dostepny w /var/www/install_log.txt"
echo "==============================================================="s
