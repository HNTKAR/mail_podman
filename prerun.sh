#!/usr/bin/bash
#/etc/postfix/main.cf
sed -i -e "/host.domain.tld/amyhostname\ =\ mail\.$domain" \
        -e "/#mydomain/amydomain\ =\ $domain" \
        -e "/#inet.*all/ s/^#//" \
        -e "/^inet.*localhost$/ s/^/#/" \
        -e "/inet_protocols/ s/all/ipv4/" \
        -e "/^mydestination/ s/^/#/" \
        -e "/^#mydestination.*\$mydomain\$/ s/^#//" \
        -e "/#local_recipient_maps\ =\ unix/ s/^#//" \
        -e "/#home_mailbox.*dir\/$/ s/^#//" \
        -e "/#smtpd.*name\$/asmtpd_banner\ =\ \$myhostname ESMTP" \
	-e "/smtpd_tls_cert_file/ s/\/.*/\/etc\/letsencrypt\/live\/mail.$domain\/fullchain.pem/" \
	-e "/smtpd_tls_key_file/ s/\/.*/\/etc\/letsencrypt\/live\/mail.$domain\/privkey.pem/" /etc/postfix/main.cf
echo """masquerade_domains = $domain
smtpd_sasl_auth_enable = yes
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
broken_sasl_auth_clients = yes
smtpd_recipient_restrictions = permit_sasl_authenticated reject_unauth_destination
""">>/etc/postfix/main.cf
echo """smtp_tls_security_level = may
smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_scache
smtpd_tls_session_cache_timeout = 3600s
smtpd_tls_received_header = yes
smtpd_tls_loglevel = 1
""">>/etc/postfix/main.cf

#/etc/dovecot/dovecot.conf
sed -i -e "/#protocols/aprotocols\ =\ imap\ pop3" /etc/dovecot/dovecot.conf

#/etc/dovecot/conf.d/10-auth.conf
sed -i -e "/#disable/ s/yes/no/" \
        -e "/#disable/ s/^#//" \
        -e "/auth_mechanisms/ s/\ plain/\ plain\ login/" /etc/dovecot/conf.d/10-auth.conf

#/etc/dovecot/conf.d/10-mail.conf
sed -i -e "/^#mail_location/amail_location\ =\ maildir:~\/Maildir" /etc/dovecot/conf.d/10-mail.conf

#/etc/dovecot/conf.d/10-ssl.conf
sed -i -e "s/pki\/dovecot\/certs\/dovecot.pem/letsencrypt\/live\/mail.$domain\/fullchain.pem/" \
        -e "s/pki\/dovecot\/private\/dovecot.pem/letsencrypt\/live\/mail.$domain\/privkey.pem/" /etc/dovecot/conf.d/10-ssl.conf

#/etc/dovecot/conf.d/10-master.conf
sed -i -e "/#unix/a\ \ mode\ =\ 0666" \
        -e "/#unix/a\ \ user\ =\ postfix" \
        -e "/#unix/a\ \ group\ =\ postfix" \
        -e "/#unix/a\ \ }" \
        -e "s/#unix/unix/" \
        -e "s/#ssl/ssl/" \
        -e "s/#port/port/" \
        -e "s/110/0/" \
        -e "s/143/0/" \
        -e "s/port\ =\ $/#port\ =\ /" /etc/dovecot/conf.d/10-master.conf

#/etc/postfix/master.cf
sed -i -e "s/#submission/submission/" \
        -e "s/#smtps/smtps/" \
        -e "/smtpd_tls_wrappermode/ s/^#//" \
        -e "/smtpd_sasl_auth_enable/ s/^#//" \
	-e "$(grep -m1 -n smtpd_sasl_auth_enable /etc/postfix/master.cf|sed s/:.*//) s/^/#/" \
        -e "/smtpd_relay_restrictions/ s/^#//" \
	-e "$(grep -m1 -n smtpd_relay_restrictions /etc/postfix/master.cf|sed s/:.*//) s/^/#/" /etc/postfix/master.cf

#/etc/rsyslog.conf
sed -i -e "/imjournal/ s/^/#/" \
	-e "s/off/on/" /etc/rsyslog.conf

#/etc/pam.d/dovecot
sed -i -e "/pam_nologin/ s/auth/\#auth/" /etc/pam.d/dovecot


#----------DKIM setting----------
<<DKIM-setting

#/etc/postfix/main.cf
echo """smtpd_milters = inet:127.0.0.1:8891
non_smtpd_milters = \$smtpd_milters
milter_default_action = accept
""">>/etc/postfix/main.cf

#opendkim
mkdir -p /etc/opendkim/keys/$domain/
opendkim-genkey -D /etc/opendkim/keys/$domain/ -d $domain -s $(date "+%Y%m%d")
chown -R opendkim:opendkim /etc/opendkim/keys/$domain/

#/etc/opendkim.conf
sed -i -e "s/Mode.*v/Mode\ \ \ sv/" \
	-e "s/^KeyFile/#KeyFile/" \
	-e "/KeyTable$/ s/#\ *//" \
	-e "/SigningTable$/ s/#\ *//" \
	-e "/ExternalIgnoreList/ s/#\ *//" \
	-e "/InternalHosts/ s/#\ *//" \
	-e "/SoftwareHeader/ s/yes/no/" /etc/opendkim.conf

#/etc/opendkim/KeyTable
echo "$(date "+%Y%m%d")._domainkey.$domain $domain:$(date "+%Y%m%d"):/etc/opendkim/keys/$domain/$(date "+%Y%m%d").private" >> /etc/opendkim/KeyTable

#/etc/opendkim/SigningTable
echo "*@$domain $(date "+%Y%m%d")._domainkey.$domain" >> /etc/opendkim/SigningTable

#start mail program
/usr/sbin/opendkim -x /etc/opendkim.conf -P /var/run/opendkim/opendkim.pid
DKIM-setting
