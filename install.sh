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
read -p "Press Enter key to continue..." presskey

echo ""
echo "\033[33;1m[Step 1/2] Getting sources\033[0m"

wget https://s3.eu-west-3.amazonaws.com/neosolva.public/zimbra/zcs-8.8.15_GA_4179.UBUNTU20_64.20211118033954.tgz
tar xvfz zcs-8.8.15_GA_4179.UBUNTU20_64.20211118033954.tgz

echo ""
echo "\033[33;1m[Step 2/2] Running Zimbra installer\033[0m"

cd zcs-8.8.15_GA_4179.UBUNTU20_64.20211118033954
sudo ./install.sh
cd ..

echo ""
echo "\033[32;1mZimbra Server installed successfully.\033[0m"
echo ""

echo "\033[33;1mThe system will now restart. When restarted, run the script 'certbot.sh' to enable HTTPS.\033[0m"
sudo reboot