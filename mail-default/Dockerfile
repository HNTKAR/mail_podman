FROM centos
MAINTAINER kusari-k

RUN yum update -y
RUN yum install -y cyrus-sasl-plain epel-release dovecot postfix
RUN yum install -y opendkim 
RUN yum clean all

EXPOSE 25 995 993 465 587 


COPY 10-auth.conf \
     10-mail.conf \
     10-ssl.conf \
     10-master.conf /etc/dovecot/conf.d/

COPY KeyTable \
     SigningTable /etc/opendkim/

COPY dovecot.conf /etc/dovecot/

COPY main.cf \
     master.cf /etc/postfix/

COPY opendkim.conf /etc/

RUN chmod 644 /etc/dovecot/conf.d/10-auth.conf \
              /etc/dovecot/conf.d/10-mail.conf \
              /etc/dovecot/conf.d/10-ssl.conf \
              /etc/dovecot/conf.d/10-master.conf \
              /etc/dovecot/dovecot.conf

RUN chmod 640 /etc/opendkim/KeyTable \
              /etc/opendkim/SigningTable
RUN chmod 644 /etc/opendkim.conf

RUN chmod 644 /etc/postfix/main.cf \
              /etc/postfix/master.cf

COPY myapp.sh /usr/local/bin/
RUN  chmod 755 /usr/local/bin/myapp.sh
ENTRYPOINT ["/usr/local/bin/myapp.sh"]
