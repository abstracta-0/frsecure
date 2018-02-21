#!/bin/bash
echo "Updating OpenVAS Databases"
systemctl is-active --quiet openvas-scanner.service

status=$(echo $?)

while [ $status != 0 ];do
	systemctl start openvas-scanner
	status=$(echo $?)
done

systemctl is-active --quiet openvas-manager.service
status=$(echo $?)

while [ $status != 0 ];do
	systemctl start openvas-manager
	status=$(echo $?)
done

systemctl is-active --quiet greenbone-security-assistant.service
status=$(echo $?)

while [ $status != 0 ];do
	systemctl start greenbone-security-assistant
	status=$(echo $?)
done

greenbone-nvt-sync
greenbone-scapdata-sync
greenbone-certdata-sync

openvasmd --update
