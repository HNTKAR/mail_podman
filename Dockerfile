FROM centos
MAINTAINER kusari-k

ARG SSL_DOMAIN 
ARG USER_DOMAIN

RUN sed -i -e "\$a fastestmirror=true" /etc/dnf/dnf.conf
RUN dnf update -y && \
	dnf install -y rsyslog postfix cyrus-imapd cyrus-sasl cyrus-sasl-plain && \
	dnf clean all

EXPOSE 25 587 993 995 110 119 143 406 563 993 995 1109 2003 2004 2005 3905 4190

#/etc/postfix/main.cf
RUN postconf -e "inet_interfaces=all" && \
	postconf -e "mydestination=localhost" && \
	postconf -e "smtpd_tls_cert_file=/etc/letsencrypt/live/$SSL_DOMAIN/fullchain.pem" && \
	postconf -e "smtpd_tls_key_file=/etc/letsencrypt/live/$SSL_DOMAIN/privkey.pem" && \
	postconf -e "myhostname=localhost" && \
	postconf -e "home_mailbox = Maildir/"

#postconf -e "masquerade_domains ="
#postconf -e ""
#RUN sed -i -e "/host.domain.tld/a myhostname\ =\ localhost" \
#	-e "/#mydomain/a mydomain\ =\ localhost" \
#	-e "/#inet.*all/ s/^#//" \
#	-e "/^inet.*localhost$/ s/^/#/" \
#	-e "/inet_protocols/ s/all/ipv4/" \
#	-e "/^mydestination/a mydestination\ =\ localhost" \
#	-e "/^mydestination/ s/^/#/" \
#	-e "/#local_recipient_maps\ =\ unix/ s/^#//" \
#	-e "/^#mynetworks_style.*host/ s/#//" \
#	-e "/#home_mailbox.*dir\/$/ s/^#//" \
#	-e "/#smtpd.*name\$/a smtpd_banner\ =\ \$myhostname ESMTP" \
#	-e "/smtpd_tls_cert_file/ s/\/.*/\/etc\/letsencrypt\/live\/$SSL_DOMAIN\/fullchain.pem/" \
#	-e "/smtpd_tls_key_file/ s/\/.*/\/etc\/letsencrypt\/live\/$SSL_DOMAIN\/privkey.pem/" \
#	-e "\$a masquerade_domains = $alias_DOMAIN" \
#	-e "\$a smtpd_sasl_auth_enable = yes" \
#	-e "\$a smtpd_sasl_type = dovecot" \
#	-e "\$a smtpd_sasl_path = private/auth" \
#	-e "\$a broken_sasl_auth_clients = yes" \
#	-e "\$a smtpd_recipient_restrictions = permit_sasl_authenticated reject_unauth_destination" \
#	-e "\$a smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_scache" \
#	-e "\$a smtpd_tls_session_cache_timeout = 3600s" \
#	-e "\$a smtpd_tls_received_header = yes" \
#	-e "\$a smtpd_tls_loglevel = 1" \
#	-e "\$a transport_maps = hash:/etc/postfix/transport" \
#	-e "\$a relay_domains = $alias_DOMAIN" \
#	-e "\$a unknown_relay_recipient_reject_code = 550" \
#	-e "\$a smtp_sasl_password_maps = hash:/etc/postfix/sasl_password" \
#	-e "\$a virtual_mailbox_domains = $alias_DOMAIN" \
#	-e "\$a virtual_mailbox_base = /home/mailer" \
#	-e "\$a virtual_mailbox_maps = hash:/etc/postfix/virtual_mailbox" \
#	-e "\$a virtual_uid_maps = static:50000" \
#	-e "\$a virtual_gid_maps = static:50000" \
#	-e "\$a virtual_alias_maps = hash:/etc/postfix/virtual_alias" /etc/postfix/main.cf

#/etc/dovecot/dovecot.conf
#RUN sed -i -e "/#protocols/a protocols\ =\ imap\ pop3" /etc/dovecot/dovecot.conf

#/etc/dovecot/conf.d/10-auth.conf
#RUN sed -i -e "/#disable/ s/yes/no/" \
#	-e "/#disable/ s/^#//" \
#	-e "/auth_mechanisms/ s/\ plain/\ plain\ login/" /etc/dovecot/conf.d/10-auth.conf

#/etc/dovecot/conf.d/10-mail.conf
#RUN sed -i -e "/^#mail_location/a mail_location\ =\ maildir:~\/Maildir" /etc/dovecot/conf.d/10-mail.conf

#/etc/dovecot/conf.d/10-ssl.conf
#RUN sed -i -e "s/pki\/dovecot\/certs\/dovecot.pem/letsencrypt\/live\/$SSL_DOMAIN\/fullchain.pem/" \
#	-e "s/pki\/dovecot\/private\/dovecot.pem/letsencrypt\/live\/$SSL_DOMAIN\/privkey.pem/" /etc/dovecot/conf.d/10-ssl.conf

#/etc/dovecot/conf.d/10-master.conf
#RUN sed -i -e "/#unix/a \ \ mode\ =\ 0666" \
#	-e "/#unix/a \ \ user\ =\ postfix" \
#	-e "/#unix/a \ \ group\ =\ postfix" \
#	-e "/#unix/a \ \ }" \
#	-e "s/#unix/unix/" \
#	-e "s/#ssl/ssl/" \
#	-e "s/#port/port/" \
#	-e "s/110/0/" \
#	-e "s/143/0/" \
#	-e "s/port\ =\ $/#port\ =\ /" /etc/dovecot/conf.d/10-master.conf

#/etc/postfix/master.cf
#RUN sed -i -e "s/#submission/submission/" \
#	-e "s/#smtps/smtps/" \
#	-e "/smtpd_tls_wrappermode/ s/^#//" \
#	-e "/smtpd_sasl_auth_enable/ s/^#//" \
#	-e "$(grep -m1 -n smtpd_sasl_auth_enable /etc/postfix/master.cf|sed s/:.*//) s/^/#/" \
#	-e "/smtpd_relay_restrictions/ s/^#//" \
#	-e "$(grep -m1 -n smtpd_relay_restrictions /etc/postfix/master.cf|sed s/:.*//) s/^/#/" /etc/postfix/master.cf

#/etc/sasl2/smtpd.conf
RUN sed -i -e "s/saslauthd/auxprop/" /etc/sasl2/smtpd.conf

#/etc/dovecot/conf.d/10-auth.conf
#RUN sed -i -e "/auth-system/ s/^/#/" \
#	-e "/auth-passwdfile/ s/^#//" /etc/dovecot/conf.d/10-auth.conf

#/etc/dovecot/conf.d/auth-passwdfile.conf.ext
#RUN sed -i -e "/args/ s/=.*/=\ \/etc\/dovecot\/passwd/" /etc/dovecot/conf.d/auth-passwdfile.conf.ext

#/etc/rsyslog.conf
RUN sed -i -e "/imjournal/ s/^/#/" \
	-e "s/off/on/" /etc/rsyslog.conf

#RUN useradd -m -u 50000 -s /sbin/nologin mailer

COPY setting.log run.sh  /usr/local/bin/
RUN  chmod 755 /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]
