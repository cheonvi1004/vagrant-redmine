#!/bin/bash

NAME=${1:-"example.com"}
ADMIN=${2:-"JDoe@example.com"}
ROOT=${3:-/var/www/html/}
DIR=${4:-""} # OPTIONAL - Must not include pre slash, and must include trailing slash

build_log=/home/ubuntu/build.log

##########################
# Ensure Root privileges #
##########################
if [ "$(whoami)" != "root" ]; then
  echo "!- You will need to run this with root, or sudo. -!"
  exit 1
fi

echo -e "\n=============================\n=== Provisioning Apache 2 ===\n=============================\n"

apt-get update -qq

echo -e "\n--- Installing [Apache 2] ---\n"
  apt install apache2 -y >> $build_log 2>&1

## Enable apache modules
echo -e "\n--- Enabling Apache module [rewrite] ---\n"
  a2enmod rewrite >> $build_log 2>&1

echo -e "\n--- Enabling Apache module [php7.0] ---\n"
  a2enmod php7.0 >> $build_log 2>&1

echo -e "\n--- Enabling Apache module [mpm_prefork] ---\n"
  a2enmod mpm_prefork >> $build_log 2>&1

## Disable apache modules
echo -e "\n--- Disabling Apache module [mpm_event] ---\n"
  a2dismod mpm_event >> $build_log 2>&1


## Create virtual host file for project
echo -e "\n--- Creating Virualhost file for $NAME ---\n"
cat <<EOF > /etc/apache2/sites-available/$NAME.conf
<VirtualHost *:80>
        ServerAdmin ${ADMIN}
        DocumentRoot ${ROOT}${DIR}
        ServerName ${NAME}
        <Directory ${ROOT}>
                Options FollowSymLinks
                AllowOverride All
                Require all granted
        </Directory>
        ErrorLog /var/log/apache2/${NAME}-error_log
        CustomLog /var/log/apache2/${NAME}-access_log common
</VirtualHost>
EOF

## Remove default web server directory tags from apache2.conf for security
echo -e "\n--- Removing default web server directory from apache2.conf ---\n"
  sed -i '/^<Directory[ ]\/var\/www\/>/,/<\/Directory>/d' /etc/apache2/apache2.conf >> $build_log 2>&1

echo -e "\n--- Removing /usr/share web server directory from apache2.conf ---\n"
  sed -i '/^<Directory[ ]\/usr\/share\/>/,/<\/Directory>/d' /etc/apache2/apache2.conf >> $build_log 2>&1

echo -e "\n--- Enabling $NAME --\n"
  a2ensite $NAME >> $build_log 2>&1

## Restart apache
echo -e "\n--- Restart Apache --\n"
  service apache2 start >> $build_log 2>&1
