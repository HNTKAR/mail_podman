#!/bin/bash

cd $(dirname $0)

#read setting file

sed -z -e "s/.*##\+mail#*//g" \
	-e "s/##.\+//g" setting.txt >setting.log

#build image
read -p "do you want to up this container ? (y/n):" yn
if [ ${yn,,} = "y" ]; then
	podman rmi -f mail
	podman build -f Dockerfile -t mail:latest
fi

rm *.log
