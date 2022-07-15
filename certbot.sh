#!/bin/bash

echo
echo "\033[41;37;1m /!\ CERBOT INSTALLATION FOR ZIMBRA /!\\" "\\033[0m"
echo

if [ -z "$1" ]
then
	ZIMBRA_SERVER_DOMAIN=$(hostname --fqdn)
else
	ZIMBRA_SERVER_DOMAIN=$1
fi

echo "Domain:" $1
echo

echo "\033[33;1mInstalling certbot with snap\033[0m"
sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/local/sbin/certbot

echo "\033[33;1mCertifying hostname\033[0m"
sudo /usr/local/sbin/certbot certonly -d $ZIMBRA_SERVER_DOMAIN --standalone --preferred-chain "ISRG Root X1" --agree-tos --register-unsafely-without-email

echo "\033[33;1mConfiguring cron job\033[0m"
cat >> /usr/local/sbin/letsencrypt-zimbra << EOF
#!/bin/bash
/usr/local/sbin/certbot certonly -d $ZIMBRA_SERVER_DOMAIN --standalone --manual-public-ip-logging-ok -n --preferred-chain  "ISRG Root X1" --agree-tos --register-unsafely-without-email
cp "/etc/letsencrypt/live/$ZIMBRA_SERVER_DOMAIN/privkey.pem" /opt/zimbra/ssl/zimbra/commercial/commercial.key
chown zimbra:zimbra /opt/zimbra/ssl/zimbra/commercial/commercial.key
wget -O /tmp/ISRG-X1.pem https://letsencrypt.org/certs/isrgrootx1.pem.txt
rm -f "/etc/letsencrypt/live/$ZIMBRA_SERVER_DOMAIN/chainZimbra.pem"
cp "/etc/letsencrypt/live/$ZIMBRA_SERVER_DOMAIN/chain.pem" "/etc/letsencrypt/live/$ZIMBRA_SERVER_DOMAIN/chainZimbra.pem"
cat /tmp/ISRG-X1.pem >> "/etc/letsencrypt/live/$ZIMBRA_SERVER_DOMAIN/chainZimbra.pem"
chown zimbra:zimbra /etc/letsencrypt -R
cd /tmp
su zimbra -c '/opt/zimbra/bin/zmcertmgr deploycrt comm "/etc/letsencrypt/live/$ZIMBRA_SERVER_DOMAIN/cert.pem" "/etc/letsencrypt/live/$ZIMBRA_SERVER_DOMAIN/chainZimbra.pem"'
rm -f "/etc/letsencrypt/live/$ZIMBRA_SERVER_DOMAIN/chainZimbra.pem"
EOF
sudo chmod +rx /usr/local/sbin/letsencrypt-zimbra
sudo ln -s /usr/local/sbin/letsencrypt-zimbra /etc/cron.daily/letsencrypt-zimbra
sudo /etc/cron.daily/letsencrypt-zimbra
sudo su zimbra -c '/opt/zimbra/bin/zmcontrol restart'