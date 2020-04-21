#!/usr/bin/bash

#start rsyslog
rsyslogd

if [ $relay = "on" ] && [ -e /usr/local/bin/user.log ]; then
	echo "test1">>test.sample
	grep "^virtual_mailbox_domains" /etc/postfix/main.cf | \
		sed -e "/^virtual_mailbox_domains/ s/,/\n/g" \
			-e "s/.*=//g">/usr/local/bin/domain.log
	xargs -a /usr/local/bin/domain.log -I {} echo  "{}	smtp:{}:587">>/etc/postfix/transport
	xargs -a /usr/local/bin/domain.log -I {} grep -m 1 {} /usr/local/bin/user.log>/usr/local/bin/password.log
	sed -e "s/.*@//g" \
		-e "s/:.*//g" \
		-e "s/$/:587\ /" /usr/local/bin/password.log>/usr/local/bin/temp.log
	paste /usr/local/bin/temp.log /usr/local/bin/password.log>/etc/postfix/sasl_password 
	sed -i -e "/^virtual/d" /etc/postfix/main.cf
	touch /etc/postfix/transport
	postmap /etc/postfix/transport
	touch /etc/postfix/sasl_password 
	postmap /etc/postfix/sasl_password 
	rm /usr/local/bin/*.log

elif [ -e /usr/local/bin/user.log ]; then
	echo "test2">>test.sample
	sed -i -e "s/\@/\ /g" \
		-e "s/:/\ /g" /usr/local/bin/user.log
	xargs -n 3 -a /usr/local/bin/user.log bash -c 'mkdir -p /home/mailer/$1/$0/Maildir'
	xargs -n 3 -a /usr/local/bin/user.log bash -c 'chown -R mailer:mailer /home/mailer/$1/$0'
	xargs -n 3 -a /usr/local/bin/user.log bash -c 'echo "$0@$1 $1/$0/Maildir/">>/etc/postfix/virtual_mailbox'
	xargs -n 3 -a /usr/local/bin/user.log bash -c 'echo $2 | saslpasswd2 -c -u $1 $0'
	xargs -n 3 -a /usr/local/bin/user.log bash -c 'echo "$0@$1:$(doveadm pw -s SHA512-CRYPT -p $2):50000:500000:::::Maildir:/home/mailer/$1/$0/Maildir/">>/etc/dovecot/passwd'
	chown -R postfix:postfix /etc/sasldb2
	touch /etc/postfix/virtual_mailbox && \
	postmap /etc/postfix/virtual_mailbox
	touch /etc/postfix/virtual_alias && \
	postmap /etc/postfix/virtual_alias
	sed -i -e "/^transport_maps/d" \
		-e "/^relay_domains/d" \
		-e "/^unknown_relay_recipient_reject_code/d" \
		-e "/^smtp_sasl_password_maps/d" /etc/postfix/main.cf
	rm /usr/local/bin/*.log
fi

#start postfix
/usr/libexec/postfix/aliasesdb && \
	/usr/libexec/postfix/chroot-update && \
	postfix start

#start dovecot
/usr/libexec/dovecot/prestartscript && \
	dovecot

tail -f /dev/null
