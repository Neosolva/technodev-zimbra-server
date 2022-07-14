#!/bin/bash

echo
echo -e "\033[41;37;1m /!\ CERBOT INSTALLATION FOR ZIMBRA /!\\" "\\033[0m"

echo -e "\033[33;1mInstalling certbot with snap\033[0m"
sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/local/sbin/certbot

echo -e "\033[33;1mCertifying hostname\033[0m"
/usr/local/sbin/certbot certonly -d $(hostname --fqdn) --standalone --preferred-chain  "ISRG Root X1" --agree-tos --register-unsafely-without-email

echo -e "\033[33;1mConfiguring cron job\033[0m"
cat >> /usr/local/sbin/letsencrypt-zimbra << EOF
#!/bin/bash
/usr/local/sbin/certbot certonly -d $(hostname --fqdn) --standalone --manual-public-ip-logging-ok -n --preferred-chain  "ISRG Root X1" --agree-tos --register-unsafely-without-email
cp "/etc/letsencrypt/live/$(hostname --fqdn)/privkey.pem" /opt/zimbra/ssl/zimbra/commercial/commercial.key
chown zimbra:zimbra /opt/zimbra/ssl/zimbra/commercial/commercial.key
wget -O /tmp/ISRG-X1.pem https://letsencrypt.org/certs/isrgrootx1.pem.txt
rm -f "/etc/letsencrypt/live/$(hostname --fqdn)/chainZimbra.pem"
cp "/etc/letsencrypt/live/$(hostname --fqdn)/chain.pem" "/etc/letsencrypt/live/$(hostname --fqdn)/chainZimbra.pem"
cat /tmp/ISRG-X1.pem >> "/etc/letsencrypt/live/$(hostname --fqdn)/chainZimbra.pem"
chown zimbra:zimbra /etc/letsencrypt -R
cd /tmp
su zimbra -c '/opt/zimbra/bin/zmcertmgr deploycrt comm "/etc/letsencrypt/live/$(hostname --fqdn)/cert.pem" "/etc/letsencrypt/live/$(hostname --fqdn)/chainZimbra.pem"'
rm -f "/etc/letsencrypt/live/$(hostname --fqdn)/chainZimbra.pem"
EOF
chmod +rx /usr/local/sbin/letsencrypt-zimbra
ln -s /usr/local/sbin/letsencrypt-zimbra /etc/cron.daily/letsencrypt-zimbra
/etc/cron.daily/letsencrypt-zimbra

sudo su zimbra -c '/opt/zimbra/bin/zmcontrol restart'