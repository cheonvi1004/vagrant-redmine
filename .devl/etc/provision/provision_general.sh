#!/bin/bash

vagrant_build_log=/home/ubuntu/vm_build.log

echo -e "\n===================================\n=== General Server Provisioning ===\n===================================\n"

echo -e "\n--- Updating Apt ---\n"
apt update >> $vagrant_build_log 2>&1

echo -e "\n--- Installing ntpdate for time sync ---\n"
  apt-get install ntpdate -y >> $vagrant_build_log 2>&1

echo -e "\n--- Syncing time with ntp.ubuntu.com ---\n"

sudo /usr/sbin/ntpdate ntp.ubuntu.com >> $vagrant_build_log 2>&1

if sudo grep -Fxq "0 5 * * * /usr/sbin/ntpdate ntp.ubuntu.com >> /dev/null 2>&1" /var/spool/cron/crontabs/root
then
  echo -e "\n--- Skipping ntpdate cron sync, line exists ---\n"
else
  echo -e "\n--- Adding ntpdate sync line to root crontab ---\n"
  
  #write out current crontab
  crontab -l > ohmycron >> $vagrant_build_log 2>&1
  
  #echo new cron into cron file
  echo "0 5 * * * /usr/sbin/ntpdate ntp.ubuntu.com >> /dev/null 2>&1"  >> ohmycron
  
  #install new cron file
  crontab ohmycron
  rm ohmycron
fi