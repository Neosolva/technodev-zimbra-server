#!/bin/bash

echo
echo "\033[41;37;1m /!\ ZIMBRA SERVER INSTALLATION /!\\" "\\033[0m"
echo

wget https://files.zimbra.com/downloads/8.8.15_GA/zcs-8.8.15_GA_4179.UBUNTU20_64.20211118033954.tgz
tar xvfz zcs-8.8.15_GA_4179.UBUNTU20_64.20211118033954.tgz
cd zcs-8.8.15_GA_4179.UBUNTU20_64.20211118033954
sh install.sh

sudo -i
su - zimbra
zmprov ms `zmhostname` -zimbraServiceEnabled dnscache -zimbraServiceInstalled dnscache
exit
exit

echo "\033[33;1mSystem reboot\033[0m"
echo "System reboot."
sudo reboot