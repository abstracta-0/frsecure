#!/bin/bash

echo "********************************"
date
echo "********************************"

apt-get update && apt-get dist-upgrade -y

echo "++++++++++++++++++++++++++++++++"
echo "apt-get autoremove -y && apt-get clean -y"
echo "++++++++++++++++++++++++++++++++"
apt-get autoremove -y

apt-get clean -y
