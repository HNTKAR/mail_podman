#!/usr/bin/bash

#start rsyslog
rsyslogd

#start cyrus
sudo -u cyrus /usr/libexec/cyrus-imapd/mkimap
/usr/libexec/cyrus-imapd/cyrus-master -d

tail -f /dev/null
