#!/usr/bin/bash

mkdir -p -m 644 /log/log /log/postfix_log /conf

#start rsyslog
rsyslogd

#start postfix
/usr/libexec/postfix/aliasesdb
/usr/libexec/postfix/chroot-update
/usr/sbin/postfix -c /conf start

tail -f /dev/null
