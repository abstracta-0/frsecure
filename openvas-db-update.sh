#!/bin/bash
echo "***************************************"
echo "Updating OpenVAS Databases"
date
echo "***************************************"
systemctl is-active --quiet openvassd.service

status=$(echo $?)

while [ $status != 0 ];do
	systemctl start openvassd.service
	status=$(echo $?)
done

systemctl is-active --quiet openvasmd.service
status=$(echo $?)

while [ $status != 0 ];do
	systemctl start openvasmd.service
	status=$(echo $?)
done

## dont want GSAD restart all the time
#systemctl is-active --quiet gsad.service
#status=$(echo $?)

#while [ $status != 0 ];do
#	systemctl start gsad.service
#	status=$(echo $?)
#done

greenbone-nvt-sync
greenbone-scapdata-sync
greenbone-certdata-sync

openvasmd --update
