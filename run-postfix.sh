#!/usr/bin/bash

mkdir -p -m 644 /spool /conf /log
chown root:root /spool /conf /log
touch /conf/sasldb2
chmod 644 /conf/sasldb2
chown root:postfix /conf/sasldb2

if [ ! -e /conf/main.cf ];then
	cp /etc/postfix/main.cf /conf/main.cf
fi

if [ ! -e /conf/master.cf ];then
	cp /etc/postfix/master.cf /conf/master.cf
fi

grep "^user:" /usr/local/bin/setting.log | \
	sed "s/^user://" | \
	awk -F '[:@]' '{print $1,$2,$3}' | \
	sed -ze "s/\n/ /g" | \
	xargs -n 3 -d " " bash -c 'echo $2|saslpasswd2 -c -p -f /conf/sasldb2 -u $1 $0'
sasldblistusers2 -f /conf/sasldb2 | \
	sed -e "s/:.*//g"|xargs -I {} echo {} {} > /conf/vmailbox
postmap /conf/vmailbox
chmod 644 /etc/postfix/vmailbox

rm /usr/local/bin/setting.log

#start rsyslog
rsyslogd

#start postfix
#/usr/libexec/postfix/aliasesdb
#/usr/libexec/postfix/chroot-update
/usr/sbin/postfix -c /conf start

tail -f /dev/null
