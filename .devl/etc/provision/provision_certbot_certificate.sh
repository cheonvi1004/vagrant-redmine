#!/bin/bash

URL=${1:-"example.org"}
WEBROOT=${2:-"/var/www/html"}
ADMIN_EMAIL=${3:-"example@example.org"}

vagrant_build_log=/home/ubuntu/vm_build.log

##########################
# Ensure Root privileges #
##########################
if [ "$(whoami)" != "root" ]; then
  echo "!- You will need to run this with root, or sudo. -!"
  exit 1
fi

echo -e "\n--- Generating Certbot SSL Cert for $URL ---\n"
sudo certbot \
  --nginx -n \
  --agree-tos \
  --redirect \
  --keep-until-expiring \
  -m $ADMIN_EMAIL \
  -d $URL \
  --renew-hook "/home/ubuntu/certbot_renewal_email.sh $EMAIL $URL" \
  --webroot-path $WEBROOT >> $vagrant_build_log 2>&1