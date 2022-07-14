#!/bin/bash

echo
echo "\033[41;37;1m /!\ ZIMBRA SERVER PRE-INSTALLATION /!\\" "\\033[0m"
echo

if [ -z "$1" ]
then
	echo "Missing argument #1: domain."
	exit
else
	ZIMBRA_SERVER_DOMAIN=$1
	echo "Domain:" $1
	echo
fi

echo "\033[33;1mSystem updates\033[0m"
sudo apt update && sudo apt upgrade -y
sudo apt install -y net-tools build-essential sqlite3 sysstat ntp libaio1 pax

echo "\033[33;1mSetting hostname\033[0m"
sudo hostnamectl set-hostname $ZIMBRA_SERVER_DOMAIN
sudo sed -i "s/\(preserve_hostname: *\).*/\1true/" /etc/cloud/cloud.cfg
sudo echo "127.0.0.1 $(hostname --fqdn)" | sudo tee -a /etc/hosts

echo "\033[33;1mSystem reboot\033[0m"
echo "System reboot. When restarted, run the script 'install.sh'."
sudo reboot