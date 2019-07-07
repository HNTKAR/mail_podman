#!/usr/bin/bash

chown -R opendkim:opendkim /etc/opendkim/keys/server_name

/usr/libexec/postfix/aliasesdb
/usr/libexec/postfix/chroot-update
/usr/libexec/dovecot/prestartscript

/usr/sbin/opendkim -x /etc/opendkim.conf -P /var/run/opendkim/opendkim.pid
/usr/sbin/dovecot
/usr/libexec/postfix/master -w
/usr/sbin/postfix start
/usr/sbin/rsyslogd 

tail -f /dev/null 
