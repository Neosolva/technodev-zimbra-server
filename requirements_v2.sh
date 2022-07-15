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

echo "\033[33;1m[Step 1/4] System update and package installation\033[0m"

sudo apt update && sudo apt upgrade -y
sudo apt install -y wget perl perl-core unzip screen nmap nc sed sysstat libaio net-tools build-essential sqlite3 ntp libaio1 pax openssh-clients

echo "\033[33;1m[Step 2/4] Host configuration\033[0m"

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

echo "\033[33;1m[Step 3/4] Setting static DNS\033[0m"
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

echo "\033[33;1m[Step 4/4] Validation\033[0m"
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