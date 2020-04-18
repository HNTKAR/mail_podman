#!/bin/bash

#version test
version_code="1"
setting_file_version=$(sed -e "s/^##.*//g"  -e "/^$/d" setting.txt|grep version|head -n 1|sed s/.*://)
if [ "x$setting_file_version" != "x$version_code" ];then
        echo "setting.txt version error"
        exit 1;
fi;

cd $(dirname $0)

#read setting file
sed -e "s/^##.*//g"  setting.txt | \
       	sed -ze "s/.*=====general=====//g" \
	-e  "s/=====.*//g" | \
	sed -e /^$/d>general.log

sed -e "s/^##.*//g"  setting.txt | \
	sed -ze "s/.*=====mail=====//g" \
	-e  "s/=====.*//g" | \
	sed -ze "s/.*-----system data-----//g" \
	-e "s/-----.*//g" | \
	sed -e /^$/d>system.log

sed -e "s/^##.*//g"  setting.txt | \
	sed -ze "s/.*=====mail=====//g" \
	-e  "s/=====.*//g" | \
	sed -ze "s/.*-----user data-----//g" \
	-e "s/-----.*//g" | \
	sed -e /^$/d>user.log

#host setting
mkdir -m 777 -p  /home/docker_home/

#set docker-compose.yml
sed -i -e "/main_FQDN/ s/:.*/:\ $(grep main_FQDN system.log | sed s/.*://)/" docker-compose.yml
sed -i -e "/main_DOMAIN/ s/:.*/:\ $(grep main_DOMAIN system.log | sed s/.*://)/" docker-compose.yml

read -p "do you want to up this container ? (y/n):" yn
if [ ${yn,,} = "y" ]; then
	docker-compose up --build -d
	rm -fr remove_firewall.sh

	firewall_opt=$(grep firewall_block system.log | sed -e "s/.*://")
	if [ x${firewall_opt,,} = "xon" ]; then
		firewall-cmd --direct --add-chain ipv4 filter DOCKER-USER-MAIL && \
		firewall-cmd --direct --add-rule ipv4 filter DOCKER-USER 1 -j DOCKER-USER-MAIL && \
		firewall-cmd --direct --add-rule ipv4 filter DOCKER-USER-MAIL 99 -p tcp --dport 25 -j DROP && \
		firewall-cmd --direct --add-rule ipv4 filter DOCKER-USER-MAIL 99 -p tcp --dport 465 -j DROP && \
		firewall-cmd --direct --add-rule ipv4 filter DOCKER-USER-MAIL 99 -p tcp --dport 587 -j DROP && \
		firewall-cmd --direct --add-rule ipv4 filter DOCKER-USER-MAIL 99 -p tcp --dport 993 -j DROP && \
		firewall-cmd --direct --add-rule ipv4 filter DOCKER-USER-MAIL 99 -p tcp --dport 995 -j DROP && \
		grep access_ip system.log | \
			sed -e "s/.*://" | \
			xargs -I {} firewall-cmd --direct --add-rule ipv4 filter DOCKER-USER-MAIL 1 -s {} -p tcp --dport 25 -j ACCEPT && \
		grep access_ip system.log | \
			sed -e "s/.*://" | \
			xargs -I {} firewall-cmd --direct --add-rule ipv4 filter DOCKER-USER-MAIL 1 -s {} -p tcp --dport 465 -j ACCEPT && \
		grep access_ip system.log | \
			sed -e "s/.*://" | \
			xargs -I {} firewall-cmd --direct --add-rule ipv4 filter DOCKER-USER-MAIL 1 -s {} -p tcp --dport 587 -j ACCEPT && \
		grep access_ip system.log | \
			sed -e "s/.*://" | \
			xargs -I {} firewall-cmd --direct --add-rule ipv4 filter DOCKER-USER-MAIL 1 -s {} -p tcp --dport 993 -j ACCEPT && \
		grep access_ip system.log | \
			sed -e "s/.*://" | \
			xargs -I {} firewall-cmd --direct --add-rule ipv4 filter DOCKER-USER-MAIL 1 -s {} -p tcp --dport 995 -j ACCEPT && \
		grep access_ip system.log | \
			sed -e "s/.*://" | \
			xargs -I {} echo "firewall-cmd --direct --remove-rule ipv4 filter DOCKER-USER-MAIL 1 -s {} -p tcp --dport 25 -j ACCEPT">>remove_firewall.sh && \
		grep access_ip system.log | \
			sed -e "s/.*://" | \
			xargs -I {} echo "firewall-cmd --direct --remove-rule ipv4 filter DOCKER-USER-MAIL 1 -s {} -p tcp --dport 465 -j ACCEPT">>remove_firewall.sh && \
		grep access_ip system.log | \
			sed -e "s/.*://" | \
			xargs -I {} echo "firewall-cmd --direct --remove-rule ipv4 filter DOCKER-USER-MAIL 1 -s {} -p tcp --dport 587 -j ACCEPT">>remove_firewall.sh && \
		grep access_ip system.log | \
			sed -e "s/.*://" | \
			xargs -I {} echo "firewall-cmd --direct --remove-rule ipv4 filter DOCKER-USER-MAIL 1 -s {} -p tcp --dport 993 -j ACCEPT">>remove_firewall.sh && \
		grep access_ip system.log | \
			sed -e "s/.*://" | \
			xargs -I {} echo "firewall-cmd --direct --remove-rule ipv4 filter DOCKER-USER-MAIL 1 -s {} -p tcp --dport 995 -j ACCEPT">>remove_firewall.sh && \
		echo "firewall-cmd --direct --remove-rule ipv4 filter DOCKER-USER-DB 99 -p tcp --dport 25 -j DROP">>remove_firewall.sh && \
		echo "firewall-cmd --direct --remove-rule ipv4 filter DOCKER-USER-DB 99 -p tcp --dport 465 -j DROP">>remove_firewall.sh && \
		echo "firewall-cmd --direct --remove-rule ipv4 filter DOCKER-USER-DB 99 -p tcp --dport 587 -j DROP">>remove_firewall.sh && \
		echo "firewall-cmd --direct --remove-rule ipv4 filter DOCKER-USER-DB 99 -p tcp --dport 993 -j DROP">>remove_firewall.sh && \
		echo "firewall-cmd --direct --remove-rule ipv4 filter DOCKER-USER-DB 99 -p tcp --dport 995 -j DROP">>remove_firewall.sh && \
		echo "firewall-cmd --direct --remove-rule ipv4 filter DOCKER-USER 1 -j DOCKER-USER-MAIL">>remove_firewall.sh && \
		echo "firewall-cmd --direct --remove-chain ipv4 filter DOCKER-USER-MAIL">>remove_firewall.sh && \
		chmod 775 remove_firewall.sh
	fi
fi
rm *.log
