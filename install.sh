#!/bin/bash

echo
echo "\033[41;37;1m /!\ ZIMBRA SERVER INSTALLATION /!\\" "\\033[0m"
echo

echo ""
echo "Internet connectivity is required for packages installation."
echo "Estimated runtime: 15 minutes (Zimbra install can take a while depending on your machine)."
echo ""
echo "Author: Ang3 <https://github.com/Ang3>"
echo ""
read -p "Press Enter key to continue:" presskey

echo ""
echo "\033[33;1m[Step 1/2] Getting sources\033[0m"

wget https://files.zimbra.com/downloads/8.8.15_GA/zcs-8.8.15_GA_4179.UBUNTU20_64.20211118033954.tgz
tar xvfz zcs-8.8.15_GA_4179.UBUNTU20_64.20211118033954.tgz
cd zcs-8.8.15_GA_4179.UBUNTU20_64.20211118033954

echo ""
echo "\033[33;1m[Step 2/2] Zimbra installer\033[0m"

sudo ./install.sh

echo ""
echo "\033[32;1mZimbra Server installed successfully.\033[0m"
echo ""

echo "\033[33;1mThe system will now restart. When restarted, run the script 'certbot.sh' to enable HTTPS.\033[0m"
sudo reboot