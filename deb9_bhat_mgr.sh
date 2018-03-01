#!/bin/bash

# insure that the system is up to date

# dhclient

apt-get update && apt-get dist-upgrade -y

apt-get install -y texlive-latex-base texlive-latex-extra texlive-latex-recommended net-tools build-essential cmake bison flex libpcap-dev pkg-config libglib2.0-dev libgpgme11-dev uuid-dev sqlfairy xmltoman doxygen libssh-dev libksba-dev libldap2-dev libsqlite3-dev libmicrohttpd-dev libxml2-dev libxslt1-dev xsltproc clang rsync rpm nsis alien sqlite3 libhiredis-dev libgcrypt20-dev libgnutls28-dev redis-server linux-headers-$(uname -r) python python-pip mingw-w64 heimdal-multidev libpopt-dev gnutls-bin certbot nmap ufw

apt-get purge -y texlive-pstricks-doc texlive-pictures-doc texlive-latex-extra-doc texlive-latex-base-doc texlive-latex-recommended-doc 

apt-get autoremove -y
# cleanly download and compile packages/libraries to /etc/OpenVAS
mkdir /etc/OpenVAS
path="/etc/OpenVAS"
cd $(echo $path | tr -d '\r')


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

cd openvas-libraries-9.0.1/
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
sed -i 's+# unixsocket /var/run/redis/redis.sock+unixsocket /var/run/redis/redis.sock+' /etc/redis/redis.conf

sed -i 's+# unixsocketperm 700+unixsocketperm 700+' /etc/redis/redis.conf


service redis-server restart
ldconfig -v


openvassd -s > /usr/local/etc/openvas/openvassd.conf
cp /usr/local/etc/openvas/openvassd.conf /usr/local/etc/openvas/openvassd.conf.bak
sed -i 's+/tmp/redis.sock+/var/run/redis/redis.sock+' /usr/local/etc/openvas/openvassd.conf

greenbone-nvt-sync
greenbone-scapdata-sync
greenbone-certdata-sync

#when do i need to start openvassd?
openvassd
openvasmd --progress --rebuild

# something is getting hung up here
openvas-manage-certs -fa


cp /etc/OpenVAS/deb9_OpenVAS_deploy/openvas-db-update.sh /usr/local/sbin/openvas-db-update.sh

(crontab -l 2>/dev/null; echo "0 0 1-31/2 * * /usr/local/sbin/openvas-db-update.sh &") | crontab -

# need to check if this adds to the end of crontab or not!!!
(crontab -l 2>/dev/null; echo "0 0 2-30/2 * * apt-get update && apt-get dist-upgrade -y") | crontab -

# cp services to correct directories

cp /etc/OpenVAS/deb9_OpenVAS_deploy/openvas-manager.service /etc/systemd/system/openvas-manager.service
cp /etc/OpenVAS/deb9_OpenVAS_deploy/openvas-scanner.service /etc/systemd/system/openvas-scanner.service
cp /etc/OpenVAS/deb9_OpenVAS_deploy/greenbone-security-assistant.service /etc/systemd/system/greenbone-security-assistant.service

systemctl enable openvas-manager.service
systemctl enable openvas-scanner.service
systemctl enable greenbone-security-assistant.service

cp /etc/systemd/system/redis.service /etc/systemd/system/redis.service.bak
sed -i 's+PrivateTmp=yes+PrivateTmp=no+' /etc/systemd/system/redis.service

sed -i 's+#!/^.{8,}$/+!/^.{8,}$/+' /usr/local/etc/openvas/pwpolicy.conf

# remove this && DO NOT SCRIPT!!!!!!!!!!!!!!!!!!
#openvasmd --create-user=administrator --role=Admin && openvasmd --user=administrator --new-password=Password01

# or hung up here???
openvassd
openvasmd
gsad

# does this need to go after "openvas-manage-certs -fa"
#openvasmd --progress --rebuild

# redis-server background save may fail under low memory condition, changing to "1"
cp /etc/sysctl.conf /etc/sysctl.conf.bak
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
sysctl vm.overcommit_memory=1

# fix latency issues with redis-server
#echo never > /sys/kernel/mm/transparent_hugepage/enabled
#cp /etc/rc.local /etc/rc.local.bak
#sed -i 's+exit 0+echo never > /sys/kernel/mm/transparent_hugepage/enabled+' /etc/rc.local
#echo 'exit 0' >> /etc/rc.local

## /etc/rc.local creation
cp /etc/OpenVAS/deb9_OpenVAS_deploy/rc-local.service /etc/systemd/system/rc-local.service
cp /etc/OpenVAS/deb9_OpenVAS_deploy/rc.local /etc/rc.local
systemctl enable rc-local
systemctl start rc-local.service

#make alias for easier console management in userspace
echo "alias ompadm='omp --host=127.0.0.1 --port=9391 --username=admin'" >> ~/.bashrc
. ~/.bashrc

/etc/OpenVAS/deb9_OpenVAS_deploy/openvas-check-setup.sh --v9

reboot
