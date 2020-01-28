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

#write files
echo -e "\nENTRYPOINT [\"/usr/local/bin/run.sh\"]">>Dockerfile

read -p "do you want to up this container ? (y/n):" yn
if [ ${yn,,} = "y" ]; then
	docker-compose up --build -d
fi