#!/bin/bash

#read setting file
sed -z s/.*#general//  setting.txt |
	\sed -z s/#.*// |
	\sed -e /^$/d >general.log
sed -z s/.*#mail//  setting.txt |
	\sed -z s/#.*// |
	\sed -e /^$/d |
	\sed '1d' >setting_mail.log
domain=$(cat general.log |grep your_domain|cut -f 2 -d ":")

sed -i -e "s/\$domain/$domain/g" run.sh
sed -i -e "s/\$domain/$domain/g" Dockerfile

#set permission
mkdir -p /etc/opendkim
mkdir -p /var/log/docker_log
mkdir -p /home/docker_home
chmod 777 /etc/opendkim
chmod 777 /var/log/docker_log
chmod 777 /home/docker_home

echo """127.0.0.1
mail.$domain
$domain""" >TrustedHosts

#write files
cat setting_mail.log |awk -F ":" -f script.awk
echo -e "\nENTRYPOINT [\"/usr/local/bin/run.sh\"]">>Dockerfile

read -p "do you want to up this container ? (y/n):" yn
if [ ${yn,,} = "y" ]; then
	docker-compose up --build -d
fi
