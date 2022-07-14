#!/bin/bash

echo
echo -e "\033[41;37;1m /!\ ZIMBRA SERVER INSTALLATION /!\\" "\\033[0m"

wget https://files.zimbra.com/downloads/8.8.15_GA/zcs-8.8.15_GA_4179.UBUNTU20_64.20211118033954.tgz
tar xvfz zcs-8.8.15_GA_4179.UBUNTU20_64.20211118033954
cd zcs-8.8.15_GA_4179.UBUNTU20_64.20211118033954
sudo ./install.sh