#!/bin/bash

#read setting file
sed -e "s/^##.*//g"  setting.txt |\
       	sed -ze "s/.*=====general=====//g" \
	-e  "s/=====.*//g" |\
	sed -e /^$/d>general.log


sed -e "s/^##.*//g"  setting.txt |\
	sed -ze "s/.*=====mail=====//g" \
	-e  "s/=====.*//g" |\
	sed -ze "s/.*-----system data-----//g" \
	-e "s/-----.*//g" |\
	sed -e /^$/d>mail-system.log

sed -e "s/^##.*//g"  setting.txt |\
	sed -ze "s/.*=====mail=====//g" \
	-e  "s/=====.*//g" |\
	sed -ze "s/.*-----user data-----//g" \
	-e "s/-----.*//g" |\
	sed -e /^$/d>mail-user.log

domain=$(cat general.log |grep domain|cut -f 2 -d ":")
FQDN=$(cat mail-system.log |grep FQDN|cut -f 2 -d ":")

sed -i -e "s/\$domain/$domain/g" prerun.sh
sed -i -e "s/\$FQDN/$FQDN/g" prerun.sh

#write files
cat mail-user.log |awk -F ":" -f script.awk
echo -e "\nENTRYPOINT [\"/usr/local/bin/run.sh\"]">>Dockerfile

read -p "do you want to up this container ? (y/n):" yn
if [ ${yn,,} = "y" ]; then
	docker-compose up --build -d
fi
