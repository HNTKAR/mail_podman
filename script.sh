#!/bin/bash

cd $(dirname $0)

#read setting file

sed -z -e "s/.*##\+mail#*//g" \
	-e "s/##.\+//g" setting.txt >setting.log

export SSL_DOMAIN=$(grep ssl_domain setting.txt|sed "s/.*://")
export USER_DOMAIN=$(grep hostname setting.txt|sed "s/.*://")

#build image
read -p "do you want to up this container ? (y/n):" yn
if [ ${yn,,} = "y" ]; then
	podman rmi -f mail
	podman build -f Dockerfile -t mail:latest --build-arg SSL_DOMAIN=$SSL_DOMAIN
fi

rm *.log
