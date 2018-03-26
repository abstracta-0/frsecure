#!/bin/bash

# dhclient

mkdir /etc/OpenVAS
path2="/etc/OpenVAS"
cd $(echo $path2 | tr -d '\r')

git clone -b master-v2 https://github.com/abstracta-0/deb9_OpenVAS_deploy.git
chmod +x *

echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list

apt-get update && apt-get -t stretch-backports dist-upgrade -y

cp /etc/OpenVAS/deb9_OpenVAS_deploy/rc-local.service /etc/systemd/system/rc-local.service
cp /etc/OpenVAS/deb9_OpenVAS_deploy/rc.local0 /etc/rc.local
systemctl enable rc-local
systemctl daemon-reload
#systemctl start rc-local.service

apt-get autoremove -y
apt-get clean -y

reboot

#cd deb9_OpenVAS_deploy

#/bin/bash /etc/OpenVAS/deb9_OpenVAS_deploy/deb9_bhat_mgr.sh |& tee install.log
