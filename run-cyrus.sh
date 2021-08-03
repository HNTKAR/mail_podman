#!/usr/bin/bash
mkdir -pm 644 /{data,conf,log}
mkdir -pm 750 /spool /data/socket
mkdir -pm 700 /data/{backup,db,log,md5,meta,msg,proc,ptclient,quota,rpm,sieve,sync,user}
touch /conf/sasldb2
chmod 660 /conf/sasldb2
chown -R cyrus:mail /spool /data/{backup,db,log,md5,meta,msg,proc,ptclient,quota,rpm,sieve,socket,sync,user} /conf/sasldb2

if [ ! -e /conf/imapd.conf ];then
	cp /etc/imapd.conf /conf/imapd.conf
fi

if [ ! -e /conf/cyrus.conf ];then
	cp /etc/cyrus.conf /conf/cyrus.conf
fi

echo $Cpass | \
	saslpasswd2 -c -p -f /conf/sasldb2 -u mail_pod cyrus
if [ -e /usr/local/bin/master ];then
	grep "^user:" /usr/local/bin/setting.log | \
		sed "s/^user://" | \
		awk -F '[:@]' '{print $1,$2,$3}' | \
		sed -ze "s/\n/ /g" | \
		xargs -n 3 -d " " bash -c 'echo $2|saslpasswd2 -c -p -f /conf/sasldb2 -u $1 $0'
fi

rm -fr /usr/local/bin/{setting.log,master,replica}

#start rsyslog
rsyslogd

#start cyrus
su cyrus -c "/usr/libexec/cyrus-imapd/mkimap /conf/imapd.conf"
/usr/libexec/cyrus-imapd/cyrus-master -C /conf/imapd.conf -M /conf/cyrus.conf -d

tail -f /dev/null
