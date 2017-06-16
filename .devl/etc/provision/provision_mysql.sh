#!/bin/bash

# Variables
DBHOST=localhost
DBNAME=${1:-"vagrant_db"}
DBUSER=${1:-"admin"}
DBPASSWD=${2:-"SECRET"}

vagrant_build_log=/home/ubuntu/vm_build.log

##########################
# Ensure Root privileges #
##########################
if [ "$(whoami)" != "root" ]; then
  echo "!- You will need to run this with root, or sudo. -!"
  exit 1
fi

echo -e "\n=================================\n=== Provisioning MySql Server ===\n=================================\n"
             
echo -e "\n--- Updating packages list ---\n"
apt-get -qq update

# MySQL setup for development purposes ONLY
echo -e "\n--- Install MySQL specific packages and settings ---\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"

apt-get -y install mysql-server >> $vagrant_build_log 2>&1

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME" >> $vagrant_build_log 2>&1
mysql -uroot -p$DBPASSWD -e "grant all privileges on *.* to '$DBUSER'@'%' identified by '$DBPASSWD'" >> $vagrant_build_log 2>&1
sed -i '/skip-external-locking/s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i '/bind-address/s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf

echo -e "\n--- MySQL User: [${DBNAME}] Password: [${DBPASSWD}] on Database: [${DBNAME}] ---\n"

sudo service mysql restart >> $vagrant_build_log 2>&1