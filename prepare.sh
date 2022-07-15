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
sudo apt install -y net-tools build-essential sqlite3 sysstat ntp libaio1 pax resolvconf

echo "\033[33;1mSetting hostname\033[0m"
sudo hostnamectl set-hostname $ZIMBRA_SERVER_DOMAIN
sudo sed -i "s/\(preserve_hostname: *\).*/\1true/" /etc/cloud/cloud.cfg
sudo echo "35.181.127.215 $(hostname --fqdn)" | sudo tee -a /etc/hosts

echo "\033[33;1mSetting DNS\033[0m"
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo ls -lh /etc/resolv.conf
sudo rm -f /etc/resolv.conf
sudo echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
sudo echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

echo "\033[33;1mConfiguring dnsmasq\033[0m"
sudo echo "server=8.8.8.8" | sudo tee -a /etc/dnsmasq.conf
sudo echo "domain=technodev.online" | sudo tee -a /etc/dnsmasq.conf
sudo echo "mx-host=technodev.online, mail.technodev.online, 10" | sudo tee -a /etc/dnsmasq.conf
sudo echo "listen-address=127.0.0.1" | sudo tee -a /etc/dnsmasq.conf
sudo echo "address=/mail.technodev.online/35.181.127.215" | sudo tee -a /etc/dnsmasq.conf
sudo systemctl restart dnsmasq

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