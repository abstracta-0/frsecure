#!/bin/bash

service openvas-scanner status | less

echo "*************************************"
echo "*************************************"
service openvas-manager status | less

echo "*************************************"
echo "*************************************"
service greenbone-security-assistant status | less

echo "*************************************"
echo "*************************************"
service redis-server status | less

echo "*************************************"
echo "*************************************"
service rc-local status | less

echo ""
cat /etc/rc.local

echo "*************************************"
echo "*************************************"
echo "'crontab -l'"
echo ""
crontab -l
echo "*************************************"
echo "*************************************"
tail -n 40 /var/log/redis/redis-server.log
