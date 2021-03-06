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
read -p "Press Enter key to continue..." presskey

echo ""
echo "\033[33;1m[Step 1/4] System update and package installation\033[0m"

sudo apt update && sudo apt upgrade -y
sudo apt install -y net-tools resolvconf perl screen nmap sed sysstat build-essential sqlite3 ntp libaio1 pax

echo ""
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
sudo tee -a /etc/hosts <<EOF
$ZIMBRA_SERVERIP $ZIMBRA_HOSTNAME.$ZIMBRA_DOMAIN $ZIMBRA_HOSTNAME
EOF

echo ""
echo "\033[33;1m[Step 3/4] DNS configuration\033[0m"

echo "\033[33;1mSetting static DNS servers...\033[0m"
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

echo "Resetting DNS settings..."
sudo cp /etc/resolvconf/resolv.conf.d/head /etc/resolvconf/resolv.conf.d/head.backup
sudo tee /etc/resolvconf/resolv.conf.d/tail<<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

echo ""
echo "\033[33;1m[Step 4/4] Validation\033[0m"
echo ""

hostnamectl

echo ""
echo "- Server FQHN:        \033[36m $(hostname --fqdn) \033[0m"
echo "- Server Domain:      \033[36m $ZIMBRA_DOMAIN \033[0m"
echo "- Public IP Address:  \033[36m $ZIMBRA_SERVERIP \033[0m"
echo ""

echo "\033[32;1mDone. The server has been configured for the installation of Zimbra Server.\033[0m"
echo ""

echo "\033[33;1mThe system will now restart. When restarted, run the script 'install.sh' to install Zimbra Server.\033[0m"
#sudo reboot