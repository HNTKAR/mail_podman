FROM centos
MAINTAINER kusari-k

RUN sed -i -e "\$a fastestmirror=true" /etc/dnf/dnf.conf
RUN dnf update -y && \
	dnf install -y rsyslog dovecot postfix epel-release && \
	dnf clean all

EXPOSE 25 465 587 993 995
ARG main_FQDN="mail.example.com"
ARG main_DOMAIN="example.com"

#/etc/postfix/main.cf
RUN sed -i -e "/host.domain.tld/a myhostname\ =\ $main_FQDN" \
	-e "/#mydomain/a mydomain\ =\ $main_DOMAIN" \
	-e "/#inet.*all/ s/^#//" \
	-e "/^inet.*localhost$/ s/^/#/" \
	-e "/inet_protocols/ s/all/ipv4/" \
	-e "/^mydestination/ s/^/#/" \
	-e "/^#mydestination.*\$mydomain\$/ s/^#//" \
	-e "/#local_recipient_maps\ =\ unix/ s/^#//" \
	-e "/#home_mailbox.*dir\/$/ s/^#//" \
	-e "/#smtpd.*name\$/a smtpd_banner\ =\ \$myhostname ESMTP" \
	-e "/smtpd_tls_cert_file/ s/\/.*/\/etc\/letsencrypt\/live\/$main_FQDN\/fullchain.pem/" \
	-e "/smtpd_tls_key_file/ s/\/.*/\/etc\/letsencrypt\/live\/$main_FQDN\/privkey.pem/" \
	-e "\$a masquerade_domains = $main_DOMAIN" \
	-e "\$a smtpd_sasl_auth_enable = yes" \
	-e "\$a smtpd_sasl_type = dovecot" \
	-e "\$a smtpd_sasl_path = private/auth" \
	-e "\$a broken_sasl_auth_clients = yes" \
	-e "\$a smtpd_recipient_restrictions = permit_sasl_authenticated reject_unauth_destination" \
	-e "\$a smtp_tls_security_level = may" \
	-e "\$a smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_scache" \
	-e "\$a smtpd_tls_session_cache_timeout = 3600s" \
	-e "\$a smtpd_tls_received_header = yes" \
	-e "\$a smtpd_tls_loglevel = 1" /etc/postfix/main.cf

#/etc/dovecot/dovecot.conf
RUN sed -i -e "/#protocols/a protocols\ =\ imap\ pop3" /etc/dovecot/dovecot.conf

#/etc/dovecot/conf.d/10-auth.conf
RUN sed -i -e "/#disable/ s/yes/no/" \
	-e "/#disable/ s/^#//" \
	-e "/auth_mechanisms/ s/\ plain/\ plain\ login/" /etc/dovecot/conf.d/10-auth.conf

#/etc/dovecot/conf.d/10-mail.conf
RUN sed -i -e "/^#mail_location/a mail_location\ =\ maildir:~\/Maildir" /etc/dovecot/conf.d/10-mail.conf

#/etc/dovecot/conf.d/10-ssl.conf
RUN sed -i -e "s/pki\/dovecot\/certs\/dovecot.pem/letsencrypt\/live\/$main_FQDN\/fullchain.pem/" \
	-e "s/pki\/dovecot\/private\/dovecot.pem/letsencrypt\/live\/$main_FQDN\/privkey.pem/" /etc/dovecot/conf.d/10-ssl.conf

#/etc/dovecot/conf.d/10-master.conf
RUN sed -i -e "/#unix/a \ \ mode\ =\ 0666" \
	-e "/#unix/a \ \ user\ =\ postfix" \
	-e "/#unix/a \ \ group\ =\ postfix" \
	-e "/#unix/a \ \ }" \
	-e "s/#unix/unix/" \
	-e "s/#ssl/ssl/" \
	-e "s/#port/port/" \
	-e "s/110/0/" \
	-e "s/143/0/" \
	-e "s/port\ =\ $/#port\ =\ /" /etc/dovecot/conf.d/10-master.conf

#/etc/postfix/master.cf
RUN sed -i -e "s/#submission/submission/" \
	-e "s/#smtps/smtps/" \
	-e "/smtpd_tls_wrappermode/ s/^#//" \
	-e "/smtpd_sasl_auth_enable/ s/^#//" \
	-e "$(grep -m1 -n smtpd_sasl_auth_enable /etc/postfix/master.cf|sed s/:.*//) s/^/#/" \
	-e "/smtpd_relay_restrictions/ s/^#//" \
	-e "$(grep -m1 -n smtpd_relay_restrictions /etc/postfix/master.cf|sed s/:.*//) s/^/#/" /etc/postfix/master.cf

#/etc/rsyslog.conf
RUN sed -i -e "/imjournal/ s/^/#/" \
	-e "s/off/on/" /etc/rsyslog.conf

#/etc/pam.d/dovecot
RUN sed -i -e "/pam_nologin/ s/auth/\#auth/" /etc/pam.d/dovecot

COPY run.sh  /usr/local/bin/
COPY user.log  /usr/local/bin/
RUN  chmod 755 /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]
