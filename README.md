# mail Container

## _setting file format_

```
###mail###
ssl_domain:example.com
hostname:example.com,example.org,example.net
user:email1:password1
user:email2:password2
user:email3:password3
```

## _up container_

```
./script.sh
sudo firewall-cmd --add-forward-port=port=465:proto=tcp:toport=10465 --permanent
sudo firewall-cmd --add-forward-port=port=587:proto=tcp:toport=10587 --permanent
sudo firewall-cmd --add-forward-port=port=993:proto=tcp:toport=10993 --permanent
sudo firewall-cmd --add-forward-port=port=995:proto=tcp:toport=10995 --permanent
podman play kube podman.yml
#podman run -itd --pod mail_pod -v /home/podman:/podman --name mail mail
#podman exec -it mail bash
```

#### _SE-Linux setting_

```
sudo mkdir -p -m 777 /home/podman/certbot_pod/letsencrypt /home/podman/certbot_pod/log
sudo semanage fcontext -a -t container_file_t "/home/podman(/.*)?"
sudo restorecon -R /home
```


