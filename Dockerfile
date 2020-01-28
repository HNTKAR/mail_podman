FROM centos
MAINTAINER kusari-k

RUN dnf update -y
RUN dnf install -y dovecot postfix epel-release cyrus-sasl-plain passwd
RUN dnf install -y https://extras.getpagespeed.com/release-el8-latest.rpm
RUN dnf install -y opendkim 
RUN dnf update -y
RUN dnf clean all

EXPOSE 25 995 993 465 587

COPY run.sh  /usr/local/bin/
RUN  chmod 755 /usr/local/bin/run.sh

RUN  cat /etc/opendkim/keys/$domain/$(date "+%Y%m%d").txt
