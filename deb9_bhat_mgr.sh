#!/bin/bash

# insure that the system is up to date

#dhclient

# /etc/rc.local creation
cp /etc/OpenVAS/deb9_OpenVAS_deploy/rc.local /etc/rc.local
systemctl enable rc-local
systemctl daemon-reload
#systemctl start rc-local.service

apt-get install -t stretch-backports -y sudo ssh autossh screen libhiredis-dev redis-server texlive-latex-base texlive-latex-extra texlive-latex-recommended net-tools build-essential cmake bison flex libpcap-dev pkg-config libglib2.0-dev libgpgme11-dev uuid-dev sqlfairy xmltoman doxygen libssh-dev libksba-dev libldap2-dev libsqlite3-dev libmicrohttpd-dev libxml2-dev libxslt1-dev xsltproc clang rsync rpm nsis alien sqlite3  libgcrypt20-dev libgnutls28-dev linux-headers-$(uname -r) python python-pip mingw-w64 heimdal-multidev libpopt-dev gnutls-bin certbot nmap ufw

systemctl stop ssh
systemctl disable ssh
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
cp /etc/OpenVAS/deb9_OpenVAS_deploy/sshd_config.hardened /etc/ssh/sshd_config

apt-get purge -y texlive-*-doc

# cleanly download and compile packages/libraries to /etc/OpenVAS
mkdir /etc/OpenVAS
path="/etc/OpenVAS"
cd $(echo $path | tr -d '\r')

#wget -nc http://download.redis.io/releases/redis-stable.tar.gz
wget -nc http://wald.intevation.org/frs/download.php/2420/openvas-libraries-9.0.1.tar.gz
wget -nc http://wald.intevation.org/frs/download.php/2423/openvas-scanner-5.1.1.tar.gz
wget -nc http://wald.intevation.org/frs/download.php/2448/openvas-manager-7.0.2.tar.gz
wget -nc http://wald.intevation.org/frs/download.php/2429/greenbone-security-assistant-7.0.2.tar.gz
wget -nc http://wald.intevation.org/frs/download.php/2397/openvas-cli-1.4.5.tar.gz
wget -nc http://wald.intevation.org/frs/download.php/2377/openvas-smb-1.0.2.tar.gz
wget -nc http://wald.intevation.org/frs/download.php/2401/ospd-1.2.0.tar.gz
wget -nc http://wald.intevation.org/frs/download.php/2405/ospd-debsecan-1.2b1.tar.gz
wget -nc http://wald.intevation.org/frs/download.php/2218/ospd-nmap-1.0b1.tar.gz

for i in $(ls *.tar.gz); do tar zxvf $i; done

### Redis 4.0 setup ### UNTESTED ######
### this is now unneccessary b/c of stretch-backports
#cd redis-stable/
#make
#make install
#make test
#yes '' | /etc/OpenVAS/redis-stable/utils/install_server.sh
#sed -i 's+port 6379+port 0+' /etc/redis/6379.conf
#sed -i 's+# unixsocket /tmp/redis.sock+unixsocket /var/run/redis/redis.sock+' /etc/redis/6379.conf
#sed -i 's+# unixsocketperm 700+unixsocketperm 700+' /etc/redis/6379.conf
#sed -i 's+REDISPORT="6379"+REDISPORT="0"+' /etc/init.d/redis_6379
#systemctl enable redis_6379
#systemctl daemon-reload
#systemctl start redis_6379
#systemctl stop redis-server
#systemctl disable redis-server

cd /etc/OpenVAS/openvas-libraries-9.0.1/
mkdir build
cd build/
cmake ..
make
make install
cd ../../

cd openvas-manager-7.0.2/
mkdir build
cd build/
cmake ..
make
make install
cd ../../

cd openvas-scanner-5.1.1/
mkdir build
cd build/
cmake ..
make
make install
cd ../../

cd openvas-cli-1.4.5/
mkdir build
cd build/
cmake ..
make
make install
cd ../../

cd greenbone-security-assistant-7.0.2/
mkdir build
cd build/
cmake ..
make
make install
cd ../../

cd ospd-1.2.0/
python setup.py build
python setup.py install
cd ../

cd ospd-debsecan-1.2b1/
python setup.py build
python setup.py install
cd ../

cd ospd-nmap-1.0b1/
python setup.py build
python setup.py install
cd ../

cp /etc/redis/redis.conf /etc/redis/redis.conf.bak
sed -i 's+port 6379+port 0+' /etc/redis/redis.conf
sed -i 's+# unixsocket /var/run/redis/redis-server.sock+unixsocket /var/run/redis/redis-server.sock+' /etc/redis/redis.conf
sed -i 's+# unixsocketperm 700+unixsocketperm 700+' /etc/redis/redis.conf

# stop from making redis socket in /tmp/systemd-private-*-redis-server.service-*/tmp/redis.sock
## not relevant to redis 4.0
sed -i 's+PrivateTmp=yes+PrivateTmp=no+' /etc/systemd/system/redis.service

# redis-server background save may fail under low memory condition, changing to "1"
## this is a redis 3.x configuration
cp /etc/sysctl.conf /etc/sysctl.conf.bak
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
sysctl vm.overcommit_memory=1

echo 'net.ipv4.tcp_timestamps = 0' >> /etc/sysctl.conf
sysctl net.ipv4.tcp_timestamps=0

service redis-server restart
ldconfig -v

# generate an openvassd conf file from the defaul one currently running
openvassd -s > /usr/local/etc/openvas/openvassd.conf
cp /usr/local/etc/openvas/openvassd.conf /usr/local/etc/openvas/openvassd.conf.bak
sed -i 's+/tmp/redis.sock+/var/run/redis/redis-server.sock+' /usr/local/etc/openvas/openvassd.conf

greenbone-nvt-sync
greenbone-scapdata-sync
greenbone-certdata-sync

# cp services to correct directories
cp /etc/OpenVAS/deb9_OpenVAS_deploy/openvassd.service /etc/systemd/system/openvassd.service
cp /etc/OpenVAS/deb9_OpenVAS_deploy/openvasmd.service /etc/systemd/system/openvasmd.service
cp /etc/OpenVAS/deb9_OpenVAS_deploy/gsad.service /etc/systemd/system/gsad.service

# start openvas services on startup
systemctl enable openvassd.service
systemctl enable openvasmd.service
systemctl enable gsad.service
systemctl daemon-reload

# start openvas services right now
systemctl start openvassd.service
systemctl start openvasmd.service
systemctl start gsad.service

# openvassd already started so this will be successful
openvasmd --progress --rebuild

# create the certificate infrastructure
# -f # force overwrite
# -a # auto setup directories
openvas-manage-certs -fa

cp /etc/OpenVAS/deb9_OpenVAS_deploy/openvas-db-update.sh /opt/openvas-db-update.sh

# openvas database update script to run all odd days
(crontab -l 2>/dev/null; echo "0 0 1-31/2 * * /opt/openvas-db-update.sh &") | crontab -

cp /etc/OpenVAS/deb9_OpenVAS_deploy/system_update.sh /opt/system_update.sh
# system update/upgrade script to run all even days
(crontab -l 2>/dev/null; echo "0 0 2-30/2 * * /opt/system_update.sh >> /var/log/system_update.log") | crontab -

# force no blank passwords for openvas
sed -i 's+#!/^.{8,}$/+!/^.{8,}$/+' /usr/local/etc/openvas/pwpolicy.conf

# fix latency issues with redis-server
#echo never > /sys/kernel/mm/transparent_hugepage/enabled
#cp /etc/rc.local /etc/rc.local.bak
#sed -i 's+exit 0+echo never > /sys/kernel/mm/transparent_hugepage/enabled+' /etc/rc.local
#echo 'exit 0' >> /etc/rc.local

#make alias for easier console management in userspace
echo "alias ompadm='omp --host=127.0.0.1 --port=9391 --username=admin --pretty-print'" >> ~/.bashrc
. ~/.bashrc

/etc/OpenVAS/deb9_OpenVAS_deploy/openvas-check-setup.sh --v9

# Not scripted, but this is what you'll need to run to log in into the webserver and
# make 'openvas-check-setup.sh --v9' finish successfully
#openvasmd --create-user=administrator --role=Admin && openvasmd --user=administrator --new-password=

apt-get autoremove -y
apt-get clean -y
reboot
