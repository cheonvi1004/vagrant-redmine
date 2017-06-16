#!/bin/bash

DATABASE=${1:-"redmine"}
USER=${2:-"redmine"}
PASSWORD=${3:-"secret"}

build_log=/home/ubuntu/build.log

##########################
# Ensure Root privileges #
##########################
if [ "$(whoami)" != "root" ]; then
  echo "!- You will need to run this with root, or sudo -!"
  exit 1
fi

echo -e "\n============================\n=== Provisioning Redmine ===\n============================\n"

hash apache2 >/dev/null 2>&1 || { echo >&2 "Apache is required but is not installed.  Aborting."; exit 1; }
hash mysql >/dev/null 2>&1 || { echo >&2 "MySql is required but is not installed.  Aborting."; exit 1; }

echo -e "\n--- Updating packages list ---\n"
  apt-get update -qq

echo -e "\n--- Installation Pre-configuration ---\n"
# Set non-interactive instaler mode, update repos.
export DEBIAN_FRONTEND=noninteractive

# Setup and install mysql-server
debconf-set-selections <<< "redmine redmine/instances/default/database-type select mysql"
debconf-set-selections <<< "redmine redmine/instances/default/mysql/method select unix socket"
debconf-set-selections <<< "redmine redmine/instances/default/db/dbname string  ${DATABASE}"
debconf-set-selections <<< "redmine redmine/instances/default/mysql/app-pass password ${PASSWORD}"
debconf-set-selections <<< "redmine redmine/instances/default/mysql/admin-pass password ${PASSWORD}"

debconf-set-selections <<< "redmine redmine/instances/default/db/app-user string ${USER}"
debconf-set-selections <<< "redmine redmine/instances/default/app-password password ${PASSWORD}"
debconf-set-selections <<< "redmine redmine/instances/default/app-password-confirm password ${PASSWORD}"
debconf-set-selections <<< "redmine redmine/instances/default/dbconfig-install boolean true"

echo -e "\n--- Installing Redmine & Redmine-mysql ---\n"
  apt-get install -q -y redmine redmine-mysql >> $build_log 2>&1

# Extras
if [[ -n ${USE_IMAGEMAGICK} ]]; then
  echo -e "\n--- Installing imagemagick ---\n"
  sudo apt-get install -q -y ruby-rmagick imagemagick >> $build_log 2>&1
fi

# Change permissions for redmine directory.
chown www-data:www-data /usr/share/redmine >> $build_log 2>&1

echo -e "\n--- Installing Apache Module [Passenger] ---\n"
  # Install apache passenger module
  apt-get install -q -y libapache2-mod-passenger >> $build_log 2>&1

# Link redmine into apache2.
ln -s /usr/share/redmine/public /var/www/redmine >> $build_log 2>&1

echo -e "\n--- Writing Apahce Virtulahost ---\n"
# Override apache settings.
cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
      ServerAdmin webmaster@localhost
      DocumentRoot /var/www/redmine
      ErrorLog /var/log/apache2/error.log
      CustomLog /var/log/apache2/access.log combined
      <Directory /var/www/redmine>
              Options FollowSymLinks
              AllowOverride All
              Require all granted
              RailsBaseURI /
              PassengerResolveSymlinksInDocumentRoot on
      </Directory>
</VirtualHost>
EOF

# Configure passenger
cat <<EOF > /etc/apache2/mods-available/passenger.conf
<IfModule mod_passenger.c>
PassengerDefaultUser www-data
PassengerRoot /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini
PassengerDefaultRuby /usr/bin/ruby
</IfModule>
EOF


echo -e "\n--- Copying Themes ---\n"
cp -r /home/ubuntu/redmine/.devl/themes/*  /usr/share/redmine/public/themes/ >> $build_log 2>&1

# Configure security messages.
sed -i 's|Server Tokens .*|Server Tokens Prod|g' /etc/apache2/conf-available/security.conf >> $build_log 2>&1


echo -e "\n--- Restarting Apache ---\n"
# Restart apache2
service apache2 restart >> $build_log 2>&1
