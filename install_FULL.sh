#!/bin/bash

# dhclient

mkdir /etc/OpenVAS
path2="/etc/OpenVAS"
cd $(echo $path2 | tr -d '\r')

apt-get update && apt-get dist-upgrade -y

git clone -b master-v2 https://github.com/abstracta-0/deb9_OpenVAS_deploy.git

cd deb9_OpenVAS_deploy

chmod +x *

/bin/bash /etc/OpenVAS/deb9_OpenVAS_deploy/deb9_bhat_mgr.sh |& tee install.log
