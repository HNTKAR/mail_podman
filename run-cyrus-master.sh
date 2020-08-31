#!/usr/bin/bash

#start rsyslog
rsyslogd

#start cyrus
/usr/libexec/cyrus-imapd/cyrus-master -d

tail -f /dev/null
