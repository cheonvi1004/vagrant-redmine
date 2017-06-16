#!/bin/bash
pushd $(dirname $0) > /dev/null; SCRIPTPATH=$(pwd); popd > /dev/null
INITDIR=`pwd`
TEMPLATEDIR=SCRIPTPATH/../templates

project=$1
source $SCRIPTPATH/../assets/info_box.sh
source $SCRIPTPATH/../assets/pretty_tasks.sh

clear

info_box "New Project Setup"

if [ -z "$1" ];then
  read -p "What is the project name: ${gold}" project
  echo "${default}"
else
  project=$1
fi

provision() {
  parse_flame $1
}

parse_flame() {
  vagrant=$(cat $SCRIPTPATH/../vagrant/vagrant.evil)
  flame=$(cat $SCRIPTPATH/../vagrant/provision_$1.flame)
  ember="EVIL_PROVISION_$1"
  echo "$flame"
  grep -o '\bEVIL_\w*' $SCRIPTPATH/../vagrant/provision_$1.flame | 
  {
    while read line ; do
      read -p "${cyan} Enter Value for ${line}: ${gold}" NICE </dev/tty
      flame=$(sed "s~${line}~${NICE}~g" <<< $flame)
      echo "$flame"
    done
    vagrant=$(sed 's~EVIL_PROVISION_APACHE~"'"${flame}"'"~g' <<< "$vagrant")
    #wtf="sed 's~${ember}~${flame}~g'"
    #echo $wtf
    #echo $ember
    echo "$vagrant"
    echo -e "$vagrant" > $SCRIPTPATH/../../../Vagrantfile.tst
  }

}

_menu () {
  echo "${green}  Provisioning Options"
  echo " ===================${normal}"
  echo "${magenta} 1 ${default}- Apache 2"
  echo "${magenta} 2 ${default}- PHP"
  echo "${magenta} 3 ${default}- Composer"
  echo "${magenta} 4 ${default}- Git Remote"
  echo "${magenta} 5 ${default}- MySql"
  echo "${magenta} 6 ${default}- Nginx Reverse Proxy"
  echo "${magenta} 7 ${default}- Node JS"
  echo "${magenta} 8 ${default}- PM2 for Node"
  echo "${magenta} 9 ${default}- Laravel"
  echo "${magenta} x ${default}- Done"

  echo -e "\n"
  while true; do
    read -p "${cyan} Select an option from the list above: ${gold}" answer
    case $answer in
      1 ) clear; provision "APACHE"; _menu; break;;
      2 ) clear; provision "PHP"; _menu; break;;
      3 ) clear; provision "COMPOSER"; _menu; break;;
      4 ) clear; provision "GIT_REMOTE"; _menu; break;;
      5 ) clear; provision "MYSQL"; _menu; break;;
      6 ) clear; provision "NGINX_REV_PROXY"; _menu; break;;
      7 ) clear; provision "NODE"; _menu; break;;
      8 ) clear; provision "PM2"; _menu; break;;
      9 ) clear; provision "LARAVEL"; _menu; break;;
      x ) clear; exit; break;;

      * ) echo "Please select a valid option.";;
    esac
  done
}

_menu