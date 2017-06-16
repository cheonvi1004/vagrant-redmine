#!/bin/bash

pushd $(dirname $0) > /dev/null; SCRIPTPATH=$(pwd); popd > /dev/null

source $SCRIPTPATH/assets/pretty_tasks.sh
source $SCRIPTPATH/assets/info_box.sh

ELKMASTER=${1:-"localhost"}

build_log=/home/ubuntu/build.log

##########################
# Ensure Root privileges #
##########################
if [ "$(whoami)" != "root" ]; then
  echo "!- You will need to run this with root, or sudo. -!"
  exit 1
fi

echo -e "\n==========================\n=== Installing Redmine ===\n==========================\n"

$SCRIPTPATH/../provision/provision_apache.sh "redmine.local" "deac@sfp.net" "/var/www/html/" "redmine/"

$SCRIPTPATH/../provision/provision_mysql.sh "localhost" "redmine" "admin" "secret"

$SCRIPTPATH/../provision/provision_redmine.sh "localhost" "redmine" "admin" "secret"
