#!/bin/bash

echo
echo "\033[41;37;1m /!\ ZIMBRA SERVER REQUIREMENTS /!\\" "\\033[0m"
echo

echo ""
echo "Internet connectivity is required for packages installation."
echo "Estimated runtime: less than one minute."
echo ""
echo "Author: Ang3 <https://github.com/Ang3>"
echo ""
read -p "Press Enter key to continue:" presskey

echo "\033[33;1m[Step 1/5] System update and package installation\033[0m"

sudo apt update && sudo apt upgrade -y
sudo apt install -y wget perl perl-core unzip screen nmap nc sed sysstat libaio net-tools build-essential sqlite3 ntp libaio1 pax resolvconf openssh-clients

echo "\033[33;1m[Step 2/5] Host configuration\033[0m"

echo ""
read -p "Input Zimbra Base Domain. E.g example.com : " ZIMBRA_DOMAIN
read -p "Input Zimbra Mail Server hostname (first part of FQDN). E.g mail : " ZIMBRA_HOSTNAME
read -p "Please insert your IP Address : " ZIMBRA_SERVERIP
echo ""

echo "Updating hostname..."
sudo hostnamectl set-hostname $ZIMBRA_HOSTNAME.$ZIMBRA_DOMAIN

echo "Updating file /etc/hosts..."
sudo cp /etc/hosts /etc/hosts.backup
sudo tee /etc/hosts <<EOF
127.0.0.1       localhost
$ZIMBRA_SERVERIP   $ZIMBRA_HOSTNAME.$ZIMBRA_DOMAIN       $ZIMBRA_HOSTNAME
EOF

echo "Disabling mail services if active..."
sudo systemctl disable --now postfix 2>/dev/null

echo "\033[33;1m[Step 3/5] Timezone configuration\033[0m"
read -p "Input your timezone value, example Africa/Nairobi: " TIMEZONE
sudo timedatectl set-timezone $TIMEZONE
sudo timedatectl set-ntp yes

echo "\033[33;1m[Step 4/5] Installation and configuration of Dnsmasq\033[0m"
echo ""

echo "Disabling service systemd-resolved to avoid conflict on port 53..."
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved

echo "Deleting file /etc/resolv.conf..."
sudo rm /etc/resolv.conf

echo "Installing package..."
sudo apt update && sudo apt install dnsmasq -y
sudo echo "port=53" | sudo tee -a /etc/dnsmasq.conf
sudo echo "domain-needed" | sudo tee -a /etc/dnsmasq.conf
sudo echo "bogus-priv" | sudo tee -a /etc/dnsmasq.conf
sudo echo "strict-order" | sudo tee -a /etc/dnsmasq.conf
sudo echo "domain=$ZIMBRA_DOMAIN" | sudo tee -a /etc/dnsmasq.conf
sudo echo "listen-address=127.0.0.1" | sudo tee -a /etc/dnsmasq.conf
sudo systemctl restart dnsmasq

echo "Installing dnsmasq service..."
sudo systemctl restart dnsmasq

echo "\033[33;1m[Step 5/5] Validation\033[0m"
echo ""

hostnamectl

echo ""
echo "Zimbra server hostname is: "
hostname -f

echo ""
echo "\033[33;1mDone. The server has been configured for the installation of Zimbra Server.\033[0m"
echo ""

echo "\033[33;1mThe system will now restart. When restarted, run the script 'install.sh' to install Zimbra Server.\033[0m"
sudo reboot