#!/usr/bin/bash
#start mail program
/usr/sbin/rsyslogd

/usr/libexec/postfix/aliasesdb && \
	/usr/libexec/postfix/chroot-update && \
	/usr/sbin/postfix start

/usr/libexec/dovecot/prestartscript && \
	/usr/sbin/dovecot

tail -f /dev/null 
