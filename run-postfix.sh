#!/usr/bin/bash

#start rsyslog
rsyslogd

#start postfix
/usr/libexec/postfix/aliasesdb
/usr/libexec/postfix/chroot-update
/usr/sbin/postfix start

tail -f /dev/null
