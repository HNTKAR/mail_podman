#!/usr/bin/bash

#start rsyslog
rsyslogd

#start postfix
/usr/libexec/postfix/aliasesdb
/usr/libexec/postfix/chroot-update
/usr/sbin/postfix start
#start cyrus
/usr/libexec/cyrus-imapd/cyrus-master -d

tail -f /dev/null
