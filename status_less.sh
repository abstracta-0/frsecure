#!/bin/bash
clear
service openvassd status | less

clear
service openvasmd status | less

clear
service gsad status | less

clear
service redis-server status | less

clear
service rc-local status | less

clear
less +G /etc/rc.local

clear
echo "'crontab -l'"
echo ""
crontab -l | less

clear
echo "*************************************"
echo "less +G /var/log/redis/redis-server.log" | less
echo "*************************************"
less +G /var/log/redis/redis-server.log

clear
echo "*************************************"
echo "less +G /usr/local/var/log/openvas/openvassd.messages" | less
echo "*************************************"
less +G /usr/local/var/log/openvas/openvassd.messages

clear
echo "*************************************"
echo "less +G /usr/local/var/log/openvas/openvasmd.log" | less
echo "*************************************"
less +G /usr/local/var/log/openvas/openvasmd.log

clear
echo "*************************************"
echo "less +G /usr/local/var/log/openvas/gsad.log" | less
echo "*************************************"
less +G /usr/local/var/log/openvas/gsad.log

clear
