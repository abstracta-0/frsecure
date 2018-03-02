#!/bin/bash

sed -i 's+port 6379+port 0+' /etc/redis/6379.conf
sed -i 's+# unixsocket /tmp/redis.sock+unixsocket /var/run/redis/redis.sock+' /etc/redis/6379.conf

sed -i 's+# unixsocketperm 700+unixsocketperm 700+' /etc/redis/6379.conf
sed -i 's+REDISPORT="6379"+REDISPORT="0"+' /etc/init.d/redis_6379

service redis_6379 restart
