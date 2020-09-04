# mail Container

## _setting file format_

```
###mail###
ssl_domain:example.com
hostname:example.com,example.org
user:email1:password1
user:email2:password2
user:email3:password3
relay:relay_domaiin1:relay_destination1
relay:relay_domaiin2:relay_destination2
replssl_domain:example.net
replpassword:replication_server's_cyrus_password
```

## _up container_

master

```
sudo mkdir -p -m 777 /home/podman/mail_pod/postfix /home/podman/mail_pod/postfix_log /home/podman/mail_pod/cyrus /home/podman/mail_pod/cyrus_log 
./script.sh
sudo firewall-cmd --add-forward-port=port=25:proto=tcp:toport=1025
sudo firewall-cmd --add-forward-port=port=143:proto=tcp:toport=10143
sudo firewall-cmd --add-forward-port=port=587:proto=tcp:toport=10587
sudo firewall-cmd --add-forward-port=port=993:proto=tcp:toport=10993
podman play kube podman-master.yml
#podman exec -it postfix-master bash
#podman exec -it cyrus-master bash
#podman pod rm -f mail_pod
#sudo firewall-cmd --reload
```

slave

```
sudo mkdir -p -m 777 /home/podman/mail_pod/postfix /home/podman/mail_pod/postfix_log /home/podman/mail_pod/cyrus /home/podman/mail_pod/cyrus_log 
./script.sh
sudo firewall-cmd --add-forward-port=port=25:proto=tcp:toport=1025
sudo firewall-cmd --add-forward-port=port=143:proto=tcp:toport=10143
sudo firewall-cmd --add-forward-port=port=587:proto=tcp:toport=10587
sudo firewall-cmd --add-forward-port=port=993:proto=tcp:toport=10993
podman play kube podman-slave-replica.yml
#podman exec -it postfix-slave bash
#podman exec -it cyrus-replica bash
#podman pod rm -f mail_pod
#sudo firewall-cmd --reload
```

master-systemctl 

```
podman pod create -p 1025:25 -p 10587:587 -p 10143:143 -p 10993:993 -n mail_pod
podman run -itd --pod mail_pod -v /home/podman/mail_pod/postfix:/podman -v /home/podman/mail_pod/postfix_log:/var/log --name postfix-master postfix-master
podman run -itd --pod mail_pod -v /home/podman/mail_pod/cyrus:/podman -v /home/podman/mail_pod/cyrus_log:/var/log --name cyrus-master cyrus-master
mkdir -p $HOME/.config/systemd/user/ && \
sudo loginctl enable-linger $(whoami) && \
podman generate systemd --new -n --restart-policy=always mail_pod -f >tmp.service && \
cat tmp.service | \
xargs -I {} cp {} -frp $HOME/.config/systemd/user && \
cat tmp.service | \
xargs -I {} systemctl --user enable {}
```

slave-systemctl

```
podman pod create -p 1025:25 -p 10587:587 -p 10143:143 -p 10993:993 -n mail_pod
podman run -itd --pod mail_pod -v /home/podman/mail_pod/postfix:/podman -v /home/podman/mail_pod/postfix_log:/var/log --name postfix-slave postfix-slave
podman run -itd --pod mail_pod -v /home/podman/mail_pod/cyrus:/podman -v /home/podman/mail_pod/cyrus_log:/var/log --name cyrus-replica cyrus-replica
mkdir -p $HOME/.config/systemd/user/ && \
sudo loginctl enable-linger $(whoami) && \
podman generate systemd --new -n --restart-policy=always mail_pod -f >tmp.service && \
cat tmp.service | \
xargs -I {} cp {} -frp $HOME/.config/systemd/user && \
cat tmp.service | \
xargs -I {} systemctl --user enable {}
```

