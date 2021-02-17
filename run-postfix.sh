#!/usr/bin/bash
mkdir -p -m 644 /spool /conf /log
chown root:root /spool /conf /log
touch /conf/sasldb2 /conf/transport /conf/aliases
chmod 644 /conf/sasldb2 /conf/transport /conf/vmailbox /conf/aliases
chown root:postfix /conf/sasldb2

if [ ! -e /conf/main.cf ];then
	cp /etc/postfix/main.cf /conf/main.cf
fi

if [ ! -e /conf/master.cf ];then
	cp /etc/postfix/master.cf /conf/master.cf
fi

if [ -e /usr/local/bin/master ];then
	grep "^user:" /usr/local/bin/setting.log | \
		sed "s/^user://" | \
		awk -F '[:@]' '{print $1,$2,$3}' | \
		sed -ze "s/\n/ /g" | \
		xargs -n 3 -d " " bash -c 'echo $2|saslpasswd2 -c -p -f /conf/sasldb2 -u $1 $0'
	sasldblistusers2 -f /conf/sasldb2 | \
		sed -e "s/:.*//g"|xargs -I {} echo {} {} > /conf/vmailbox
	postmap /conf/vmailbox
fi
if [ -e /usr/local/bin/slave ];then
	grep "^relay:" /usr/local/bin/setting.log | \
		sed "s/^relay://" | \
		awk -F '[:]' '{print $1" smtp:"$2}' > /conf/transport
	postmap /conf/transport
fi
postalias /conf/aliases

rm -fr /usr/local/bin/setting.log /usr/local/bin/master /usr/local/bin/slave

#start rsyslog
rsyslogd

#start postfix
#/usr/libexec/postfix/aliasesdb
#/usr/libexec/postfix/chroot-update
/usr/sbin/postfix -c /conf start

tail -f /dev/null
