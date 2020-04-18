#!/usr/bin/bash

#start rsyslog
rsyslogd

if [ -e /usr/local/bin/user.log ]; then
	sed s/:/\ / /usr/local/bin/user.log| \
		xargs -n 2 bash -c 'echo $0:$1::::/home/$0:/sbin/nologin>>/usr/local/bin/user_passwd.log'
	sed s/:.*// /usr/local/bin/user.log| \
		xargs -I {} chown -R {}:{} /home/{}
	newusers /usr/local/bin/user_passwd.log
	rm /usr/local/bin/user.log /usr/local/bin/user_passwd.log
fi

#start postfix
/usr/libexec/postfix/aliasesdb && \
	/usr/libexec/postfix/chroot-update && \
	postfix start

#start dovecot
/usr/libexec/dovecot/prestartscript && \
	dovecot

tail -f /dev/null
