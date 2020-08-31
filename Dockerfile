FROM centos
MAINTAINER kusari-k

ARG SSL_DOMAIN 
ARG USER_DOMAIN
ARG password="cyruspassword"
ENV Cpass $password

EXPOSE 25 143 587 993

RUN sed -i -e "\$a fastestmirror=true" /etc/dnf/dnf.conf
RUN dnf update -y && \
	dnf install -y rsyslog postfix cyrus-imapd cyrus-sasl cyrus-sasl-plain telnet && \
	dnf clean all

COPY setting.log run.sh /usr/local/bin/
COPY letsencrypt /etc/letsencrypt

#/etc/postfix/main.cf
RUN postconf -e "inet_interfaces=all" && \
	postconf -e "mydestination=localhost" && \
	postconf -e "myhostname=localhost" && \
	postconf -e "mydomain=localhost" && \
	postconf -e "smtpd_tls_cert_file=/etc/letsencrypt/live/$SSL_DOMAIN/fullchain.pem" && \
	postconf -e "smtpd_tls_key_file=/etc/letsencrypt/live/$SSL_DOMAIN/privkey.pem" && \
	postconf -e "smtpd_recipient_restrictions=permit_mynetworks permit_sasl_authenticated reject_unauth_destination" && \
	postconf -e "smtpd_sasl_auth_enable=yes" && \
	postconf -e "virtual_transport=lmtp:unix:/run/cyrus/socket/lmtp" && \
	postconf -e "virtual_mailbox_domains=$USER_DOMAIN" && \
	postconf -e "virtual_mailbox_maps=hash:/etc/postfix/vmailbox" && \
	postconf -e "inet_protocols =ipv4" && \
	postconf -e "smtpd_banner = ESMTP" && \
	postconf -e "smtpd_tls_loglevel = 1"

#/etc/imapd.conf
RUN sed -i -e "/sasl_pwcheck_method/ s/:.*/: auxprop/" \
	-e "/virtdomains/ s/:.*/: userid/" \
	-e "/tls_server_cert/ s/:.*/: \/etc\/letsencrypt\/live\/$SSL_DOMAIN\/fullchain.pem/" \
	-e "/tls_server_key/ s/:.*/: \/etc\/letsencrypt\/live\/$SSL_DOMAIN\/privkey.pem/" \
	-e "/tls_client_ca_file/ s/:.*/: \/etc\/letsencrypt\/live\/$SSL_DOMAIN\/chain.pem/" \
	-e "/tls_client_ca_dir/ s/:.*/: \/etc\/letsencrypt\/live\/$SSL_DOMAIN\//" \
	-e "\$a syslog_facility: LOCAL6" \
	-e "\$a autocreate_post: yes" \
	-e "\$a autocreate_quota_messages: 0" \
	-e "\$a autocreate_quota: 0" \
	-e "\$a defaultdomain: localhost" /etc/imapd.conf

#/etc/postfix/master.cf
RUN smtps_num=$(grep -n "^#smtps" /etc/postfix/master.cf|sed s/:.*//) && \
	sed -i -e "/^#submission/ s/^#//" \
	-e "1,$smtps_num  s/^#\(.*syslog_name.*\)/\1/" \
	-e "1,$smtps_num  s/^#\(.*smtpd_tls_security_level.*\)/\1/" \
	-e "1,$smtps_num  s/^#\(.*smtpd_sasl_auth_enable.*\)/\1/" \
	-e "1,$smtps_num  s/^#\(.*smtpd_tls_auth_only.*\)/\1/" \
	-e "1,$smtps_num  s/^#\(.*smtpd_reject_unlisted_recipient.*\)/\1/" \
	-e "1,$smtps_num  s/^#\(.*smtpd_recipient_restrictions.*\)/\1/" \
	-e "1,$smtps_num  s/^#\(.*smtpd_relay_restrictions.*\)/\1/" /etc/postfix/master.cf

#/etc/cyrus.conf
RUN sed -i -e "/^#.*idled/ s/#//" /etc/cyrus.conf

#/etc/sasl2/smtpd.conf
RUN sed -i -e "s/saslauthd/auxprop/" \
	-e "2i auxprop_plugin: sasldb" /etc/sasl2/smtpd.conf 

#user setting
RUN echo $password|saslpasswd2 -c -p -u mail_pod cyrus

RUN grep "^user:" /usr/local/bin/setting.log | \
	sed "s/^user://" | \
	awk -F '[:@]' '{print $1,$2,$3}' | \
	sed -ze "s/\n/ /g" | \ 
	xargs -n 3 -d " " bash -c 'echo $2|saslpasswd2 -c -p -u $1 $0'

RUN grep "^user:" /usr/local/bin/setting.log | \
	sed "s/^user://" | \
	awk -F '[:]' '{print $1,$1}' > /etc/postfix/vmailbox && \
	postmap /etc/postfix/vmailbox
	
#authority setting
RUN mkdir -p -m 750 /var/lib/cyrus /var/spool/cyrus  && \
	chown -R cyrus:mail /var/lib/cyrus /var/spool/cyrus && \
	chmod 777 /etc/sasldb2 && \
	chmod -R 777 /etc/letsencrypt && \
	chmod 644 /etc/postfix/vmailbox

#/etc/rsyslog.conf
RUN sed -i -e "/imjournal/ s/^/#/" \
	-e "s/off/on/" /etc/rsyslog.conf && \
	echo "local6.*        /var/log/imapd.log" >> /etc/rsyslog.d/cyrus.conf && \
	echo "auth.debug      /var/log/auth.log" >> /etc/rsyslog.d/cyrus.conf && \
	touch /var/log/imapd.log /var/log/auth.log

RUN  chmod 755 /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]
