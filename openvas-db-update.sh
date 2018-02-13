#!/bin/bash
echo "Updating OpenVAS Databases"
greenbone-nvt-sync
greenbone-scapdata-sync
greenbone-certdata-sync