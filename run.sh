#!/usr/bin/bash

#start rsyslog
rsyslogd

if [ -e /usr/local/bin/user.log ]; then
	sed -i -e "s/\@/\ /g" \
		-e "s/:/\ /g" /usr/local/bin/user.log
	xargs -n 3 -a /usr/local/bin/user.log bash -c 'mkdir -p /home/mailer/$1/$0/Maildir'
	xargs -n 3 -a /usr/local/bin/user.log bash -c 'chown -R mailer:mailer /home/mailer/$1/$0'
	xargs -n 3 -a /usr/local/bin/user.log bash -c 'echo "$0@$1 $1/$0/Maildir/">>/etc/postfix/virtual_mailbox'
	xargs -n 3 -a /usr/local/bin/user.log bash -c 'echo $2 | saslpasswd2 -c -u $1 $0'
	xargs -n 3 -a /usr/local/bin/user.log bash -c 'echo "$0@$1:$(doveadm pw -s SHA512-CRYPT -p $2):50000:500000:::::Maildir:/home/mailer/$1/$0/Maildir/">>/etc/dovecot/passwd'
	chown -R postfix:postfix /etc/sasldb2
	touch /etc/postfix/virtual_alias
	rm /usr/local/bin/.*\.log
fi

#start postfix
postmap /etc/postfix/virtual_mailbox && \
	postmap /etc/postfix/virtual_alias && \
	/usr/libexec/postfix/aliasesdb && \
	/usr/libexec/postfix/chroot-update && \
	postfix start

#start dovecot
/usr/libexec/dovecot/prestartscript && \
	dovecot

tail -f /dev/null
