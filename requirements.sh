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

echo ""
echo "\033[33;1m[Step 1/5] System update and package installation\033[0m"

sudo apt update && sudo apt upgrade -y
sudo apt install -y wget perl unzip screen nmap sed sysstat net-tools build-essential sqlite3 ntp libaio1 pax

echo ""
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
sudo tee -a /etc/hosts <<EOF
$ZIMBRA_SERVERIP $ZIMBRA_HOSTNAME.$ZIMBRA_DOMAIN $ZIMBRA_HOSTNAME
EOF

echo ""
echo "\033[33;1m[Step 4/5] Installation and configuration of Dnsmasq\033[0m"
echo ""

echo "Disabling service systemd-resolved to avoid conflict on port 53..."
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo mv /etc/resolv.conf /etc/resolv.conf.backup

echo "Installing package..."
sudo apt update && sudo apt install dnsmasq -y

echo "Setting config..."
sudo tee -a /etc/dnsmasq.conf <<EOF
port=53
domain-needed
bogus-priv
strict-order
domain=$ZIMBRA_DOMAIN
listen-address=127.0.0.1
EOF

echo "Restarting service..."
sudo systemctl restart dnsmasq

echo ""
echo "\033[33;1m[Step 5/5] Validation\033[0m"
echo ""

hostnamectl

echo ""
echo "- Server FQHN:        \033[36$(hostname --fqdn)\033[0m"
echo "- Server Domain:      \033[36$ZIMBRA_DOMAIN\033[0m"
echo "- Public IP Address:  \033[36$ZIMBRA_SERVERIP\033[0m"
echo ""

echo "\033[32;1mDone. The server has been configured for the installation of Zimbra Server.\033[0m"
echo ""

echo "\033[33;1mThe system will now restart. When restarted, run the script 'install.sh' to install Zimbra Server.\033[0m"
#sudo reboot