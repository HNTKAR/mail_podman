FROM centos
MAINTAINER kusari-k

RUN dnf update -y
RUN dnf install -y rsyslog dovecot postfix epel-release passwd
RUN dnf update -y
RUN dnf clean all

EXPOSE 25 995 993 465 587

COPY prerun.sh  /usr/local/bin/
RUN  chmod 755 /usr/local/bin/prerun.sh
COPY run.sh  /usr/local/bin/
RUN  chmod 755 /usr/local/bin/run.sh
RUN  /usr/local/bin/prerun.sh
