#!/bin/bash

service openvas-scanner status
echo "*************************************"
echo "*************************************"
service openvas-manager status
echo "*************************************"
echo "*************************************"
service greenbone-security-assistant status
echo "*************************************"
echo "*************************************"
service redis-server status
echo "*************************************"
echo "*************************************"
service rc-local status
echo ""
less /etc/rc.local

echo "*************************************"
echo "*************************************"
echo "'crontab -l'"
echo ""
crontab -l | less
echo "*************************************"
echo "*************************************"
tail -n 40 /var/log/redis/redis-server.log
