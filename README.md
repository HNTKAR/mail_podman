# mail Container

## _setting file format_

```
###mail###
ssl_domain:example.com
hostname:example.com,example.org,example.net
user1:email1:password1
user2:email2:password2
user3:email3:password3
```

## _up container_

master

```
./script.sh
sudo firewall-cmd --add-forward-port=port=25:proto=tcp:toport=1025
sudo firewall-cmd --add-forward-port=port=143:proto=tcp:toport=10143
sudo firewall-cmd --add-forward-port=port=587:proto=tcp:toport=10587
sudo firewall-cmd --add-forward-port=port=993:proto=tcp:toport=10993
podman play kube podman-master.yml
#podman pod create -p 1025:25 -p 10587:587 -p 10143:143 -p 10993:993 -n mail_pod
#podman run -itd --pod mail_pod -v /home/podman/mail_pod/postfix:/podman -v /home/podman/mail_pod/postfix_log:/var/log --name postfix-master postfix-master
#podman run -itd --pod mail_pod -v /home/podman/mail_pod/cyrus:/podman -v /home/podman/mail_pod/cyrus_log:/var/log --name cyrus-master cyrus-master
#podman exec -it postfix-master bash
#podman exec -it cyrus-master bash
#podman pod rm -f mail_pod
#sudo firewall-cmd --reload
```

slave

```
./script.sh
sudo firewall-cmd --add-forward-port=port=25:proto=tcp:toport=1025
sudo firewall-cmd --add-forward-port=port=143:proto=tcp:toport=10143
sudo firewall-cmd --add-forward-port=port=587:proto=tcp:toport=10587
sudo firewall-cmd --add-forward-port=port=993:proto=tcp:toport=10993
podman play kube podman-slave-replica.yml
#podman pod create -p 1025:25 -p 10587:587 -p 10143:143 -p 10993:993 -n mail_pod
#podman run -itd --pod mail_pod -v /home/podman/mail_pod/postfix:/podman -v /home/podman/mail_pod/postfix_log:/var/log --name postfix-slave postfix-slave
#podman run -itd --pod mail_pod -v /home/podman/mail_pod/cyrus:/podman -v /home/podman/mail_pod/cyrus_log:/var/log --name cyrus-replica cyrus-replica
#podman exec -it postfix-slave bash
#podman exec -it cyrus-replica bash
#podman pod rm -f mail_pod
#sudo firewall-cmd --reload
```

#### _SE-Linux setting_

```
sudo mkdir -p -m 777 /home/podman/mail_pod/postfix /home/podman/mail_pod/postfix_log /home/podman/mail_pod/cyrus /home/podman/mail_pod/cyrus_log 
sudo semanage fcontext -a -t container_file_t "/home/podman(/.*)?"
sudo restorecon -R /home/podman
```
