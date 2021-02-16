#!/usr/bin/bash
mkdir -p -m 644 /data /conf /log 
mkdir -p -m 750 /spool /data/socket
mkdir -p -m 700 /data/db
touch /conf/sasldb2
chmod 660 /conf/sasldb2
chown -R cyrus:mail /spool /data/socket  /data/db /conf/sasldb2

if [ ! -e /conf/imapd.conf ];then
	cp /etc/imapd.conf /conf/imapd.conf
fi

if [ ! -e /conf/cyrus.conf ];then
	cp /etc/cyrus.conf /conf/cyrus.conf
fi

echo $Cpass | \
	saslpasswd2 -c -p -f /conf/sasldb2 -u mail_pod cyrus
grep "^user:" /usr/local/bin/setting.log | \
	sed "s/^user://" | \
	awk -F '[:@]' '{print $1,$2,$3}' | \
	sed -ze "s/\n/ /g" | \
	xargs -n 3 -d " " bash -c 'echo $2|saslpasswd2 -c -p -f /conf/sasldb2 -u $1 $0'

rm /usr/local/bin/setting.log

#start rsyslog
rsyslogd

#start cyrus
su cyrus -c "/usr/libexec/cyrus-imapd/mkimap /conf/imapd.conf"
/usr/libexec/cyrus-imapd/cyrus-master -C /conf/imapd.conf -M /conf/cyrus.conf -d

tail -f /dev/null
