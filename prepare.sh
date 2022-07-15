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

if [ -z "$2" ]
then
	echo "Missing argument #2: private IP."
	exit
else
	PRIVATE_IP=$2
	echo "Private IP:" $2
	echo
fi

echo "\033[33;1mSystem updates\033[0m"
sudo apt update && sudo apt upgrade -y
sudo apt install -y net-tools build-essential sqlite3 sysstat ntp libaio1 pax resolvconf

echo "\033[33;1mSetting hostname\033[0m"
sudo hostnamectl set-hostname $ZIMBRA_SERVER_DOMAIN
sudo sed -i "s/\(preserve_hostname: *\).*/\1true/" /etc/cloud/cloud.cfg
sudo echo "$PRIVATE_IP $(hostname --fqdn)" | sudo tee -a /etc/hosts

echo "\033[33;1mSetting static DNS\033[0m"
sudo cat >> 99-custom-dns.yaml << EOF
network:
  version: 2
  ethernets:
    eth0:
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
      dhcp4-overrides:
        use-dns: false
EOF
sudo mv 99-custom-dns.yaml /etc/netplan/99-custom-dns.yaml

echo "\033[33;1mSystem reboot\033[0m"
echo "System reboot. When restarted, run the script 'install.sh'."
sudo reboot