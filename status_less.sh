#!/bin/bash
echo "*************************************"
echo "Welcome to the OpenVAS 'status_less.sh' script"
echo ""
echo "This will cycle through all statuses of all the relevent OpenVAS services"
echo "Then cycle through the corresponding log files with 'less'"
echo ""
echo "Use 'Q' to cycle through each dialogue"
echo "Use your arrow, 'Home' and 'End' keys to navigate log files"
echo "Use '/' to start searching through the log files"
echo "*************************************"
 
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
echo "'crontab -l'" | less
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
echo "*************************************"
echo "less +G /var/log/openvas-db-update.log" | less
echo "*************************************"
less +G /var/log/openvas-db-update.log
