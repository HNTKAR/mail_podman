#!/bin/bash

cd $(dirname $0)

#read setting file

sed -z -e "s/.*##\+mail#*//g" \
	-e "s/##.\+//g" setting.txt >setting.log

export USER_DOMAIN=$(grep ^hostname setting.log|sed "s/.*://")
export SSL_DOMAIN=$(grep ^ssl_domain setting.log|sed "s/.*://")
export password=$(cat /dev/urandom | base64 | fold -w 10|head -n 1)
export replSSL_DOMAIN=$(grep ^replssl_domain setting.log|sed "s/.*://")
export replpassword=$(grep ^replpassword setting.log|sed "s/.*://")

cp -frp /home/podman/ssl_pod/letsencrypt .

#build image
read -p "do you want to up master container ? (y/n):" yn
if [ ${yn,,} = "y" ]; then
	podman rmi -f postfix-master
	podman rmi -f cyrus-master
	podman build -f Dockerfile-cyrus-master -t cyrus-master:latest --build-arg SSL_DOMAIN=$SSL_DOMAIN --build-arg USER_DOMAIN=$USER_DOMAIN --build-arg password=$password --build-arg replSSL_DOMAIN=$replSSL_DOMAIN --build-arg replpassword=$replpassword
	podman build -f Dockerfile-postfix-master -t postfix-master:latest --build-arg SSL_DOMAIN=$SSL_DOMAIN --build-arg USER_DOMAIN=$USER_DOMAIN

fi

read -p "do you want to up replica and slave container ? (y/n):" yn
if [ ${yn,,} = "y" ]; then
	export reolpassword=$(cat /dev/urandom | base64 | fold -w 10|head -n 1)
	podman rmi -f postfix-slave
	podman rmi -f cyrus-replica
	podman build -f Dockerfile-cyrus-replica -t cyrus-replica:latest --build-arg SSL_DOMAIN=$replSSL_DOMAIN --build-arg password=$replpassword
	podman build -f Dockerfile-postfix-slave -t postfix-slave:latest --build-arg SSL_DOMAIN=$replSSL_DOMAIN --build-arg USER_DOMAIN=$USER_DOMAIN
fi

rm *.log
