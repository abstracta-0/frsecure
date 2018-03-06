#!/bin/bash

# dhclient

mkdir /etc/OpenVAS
path2="/etc/OpenVAS"
cd $(echo $path2 | tr -d '\r')

echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list

apt-get update && apt-get -t stretch-backports dist-upgrade -y

reboot

#git clone -b master-v2 https://github.com/abstracta-0/deb9_OpenVAS_deploy.git

#cd deb9_OpenVAS_deploy

#chmod +x *

#/bin/bash /etc/OpenVAS/deb9_OpenVAS_deploy/deb9_bhat_mgr.sh |& tee install.log
