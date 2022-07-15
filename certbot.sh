#!/bin/bash

echo
echo "\033[41;37;1m /!\ CERBOT INSTALLATION FOR ZIMBRA /!\\" "\\033[0m"
echo

echo ""
echo "Internet connectivity is required for packages installation."
echo "Estimated runtime: less than one minute."
echo ""
echo "Author: Ang3 <https://github.com/Ang3>"
echo ""
read -p "Press Enter key to continue..." presskey

echo ""
read -p "Input Zimbra Base Domain. E.g mail.example.com : " ZIMBRA_DOMAIN
echo ""

echo ""
echo "\033[33;1m[Step 1/4] Installing certbot with snap\033[0m"

sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/local/sbin/certbot

echo ""
echo "\033[33;1m[Step 2/4] Certifying hostname\033[0m"

sudo /usr/local/sbin/certbot certonly -d $ZIMBRA_DOMAIN --standalone --preferred-chain "ISRG Root X1" --agree-tos --register-unsafely-without-email

echo ""
echo "\033[33;1m[Step 3/4] Configuring cron job\033[0m"

cat >> letsencrypt-zimbra << EOF
#!/bin/bash
/usr/local/sbin/certbot certonly -d $ZIMBRA_DOMAIN --standalone --manual-public-ip-logging-ok -n --preferred-chain  "ISRG Root X1" --agree-tos --register-unsafely-without-email
cp "/etc/letsencrypt/live/$ZIMBRA_DOMAIN/privkey.pem" /opt/zimbra/ssl/zimbra/commercial/commercial.key
chown zimbra:zimbra /opt/zimbra/ssl/zimbra/commercial/commercial.key
wget -O /tmp/ISRG-X1.pem https://letsencrypt.org/certs/isrgrootx1.pem.txt
rm -f "/etc/letsencrypt/live/$ZIMBRA_DOMAIN/chainZimbra.pem"
cp "/etc/letsencrypt/live/$ZIMBRA_DOMAIN/chain.pem" "/etc/letsencrypt/live/$ZIMBRA_DOMAIN/chainZimbra.pem"
cat /tmp/ISRG-X1.pem >> "/etc/letsencrypt/live/$ZIMBRA_DOMAIN/chainZimbra.pem"
chown zimbra:zimbra /etc/letsencrypt -R
cd /tmp
su zimbra -c '/opt/zimbra/bin/zmcertmgr deploycrt comm "/etc/letsencrypt/live/$ZIMBRA_DOMAIN/cert.pem" "/etc/letsencrypt/live/$ZIMBRA_DOMAIN/chainZimbra.pem"'
rm -f "/etc/letsencrypt/live/$ZIMBRA_DOMAIN/chainZimbra.pem"
EOF
sudo mv letsencrypt-zimbra /usr/local/sbin/letsencrypt-zimbra
sudo chmod +rx /usr/local/sbin/letsencrypt-zimbra
sudo ln -s /usr/local/sbin/letsencrypt-zimbra /etc/cron.daily/letsencrypt-zimbra

echo ""
echo "\033[33;1m[Step 4/4] Deploy\033[0m"

sudo /etc/cron.daily/letsencrypt-zimbra
sudo su zimbra -c '/opt/zimbra/bin/zmcontrol restart'

echo ""
echo "\033[32;1mHTTPS enabled successfully.\033[0m"
echo ""