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
echo "\033[33;1m[Step 1/5] System update and package installation\033[0m"

sudo apt update && sudo apt upgrade -y
sudo apt install -y bind9 bind9utils net-tools resolvconf perl screen nmap sed sysstat build-essential sqlite3 ntp libaio1 pax

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

echo "Resetting DNS settings..."
sudo cp /etc/resolvconf/resolv.conf.d/head /etc/resolvconf/resolv.conf.d/head.backup
sudo tee /etc/resolvconf/resolv.conf.d/head<<EOF
search $ZIMBRA_DOMAIN
nameserver 127.0.0.1
nameserver $ZIMBRA_SERVERIP
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

echo "Disabling systemd-resolved and enable resolvconf..."
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl enable resolvconf
sudo systemctl restart resolvconf

echo "Updating file /etc/resolv.conf..."
sudo cp /etc/resolv.conf /etc/resolv.conf.backup
sudo tee /etc/resolv.conf<<EOF
search $ZIMBRA_DOMAIN
nameserver $ZIMBRA_SERVERIP
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

echo ""
echo "\033[33;1m[Step 5/5] DNS Server configuration\033[0m"
echo ""

echo "Backup bind configs from /etc/bind/..."
BIND_CONFIG=$(ls /etc/bind/ | grep named.conf.local.back)
if [ "$BIND_CONFIG" == "named.conf.local.back" ]; then
    sudo cp /etc/bind/named.conf.local.back /etc/bind/named.conf.local
else
    sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.back
fi

echo "Configuring zone in file /etc/bind/named.conf.local..."
sudo tee -a /etc/bind/named.conf.local<<EOF
zone "$ZIMBRA_DOMAIN" IN {
type master;
file "/etc/bind/db.$ZIMBRA_DOMAIN";
};
EOF

echo "Creating Zone database file to /etc/bind/db.$ZIMBRA_DOMAIN..."
sudo touch /etc/bind/db.$ZIMBRA_DOMAIN
sudo chgrp bind /etc/bind/db.$ZIMBRA_DOMAIN
sudo tee /etc/bind/db.$ZIMBRA_DOMAIN<<EOF
\$TTL 1D
@       IN SOA  ns1.$ZIMBRA_DOMAIN. root.$ZIMBRA_DOMAIN. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@		IN	NS	ns1.$ZIMBRA_DOMAIN.
@		IN	MX	0 $ZIMBRA_HOSTNAME.$ZIMBRA_DOMAIN.
ns1	IN	A	$ZIMBRA_SERVERIP
mail	IN	A	$ZIMBRA_SERVERIP
EOF
sudo sed -i 's/dnssec-validation yes/dnssec-validation no/g' /etc/bind/named.conf.options

echo "Configuring DNS Options in /etc/bind/named.conf.options..."
sudo tee /etc/bind/named.conf.options<<EOF
options {
	directory "/var/cache/bind";
	forwarders {
		8.8.8.8;
		1.1.1.1;
	};
	dnssec-validation auto;
	listen-on-v6 { any; };
};
EOF

# Restart Service & Check results configuring DNS Server

echo "Restarting service..."
sudo systemctl enable bind9 && sudo systemctl restart bind9

echo ""
echo "\033[33;1m[Step 5/5] Validation\033[0m"
echo ""

hostnamectl

echo ""
echo "- Server FQHN:        \033[36m $(hostname --fqdn) \033[0m"
echo "- Server Domain:      \033[36m $ZIMBRA_DOMAIN \033[0m"
echo "- Public IP Address:  \033[36m $ZIMBRA_SERVERIP \033[0m"
echo ""

echo "DNS dumping results:"
nslookup $ZIMBRA_HOSTNAME.$ZIMBRA_DOMAIN
dig $ZIMBRA_DOMAIN mx

echo "\033[32;1mDone. The server has been configured for the installation of Zimbra Server.\033[0m"
echo ""

echo "\033[33;1mThe system will now restart. When restarted, run the script 'install.sh' to install Zimbra Server.\033[0m"
#sudo reboot