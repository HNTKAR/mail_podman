# mail Container

## _setting file format_

```
###mail###
ssl_domain:example.com
hostname:example.com,example.org,example.net
```

## _up container_

```
./script.sh
podman run -itd --pod mail_pod -v /home/podman:/podman --name mail mail
podman exec -it mail bash
```

#### _SE-Linux setting_

```
sudo mkdir -p -m 777 /home/podman/certbot_pod/letsencrypt /home/podman/certbot_pod/log
sudo semanage fcontext -a -t container_file_t "/home/podman(/.*)?"
sudo restorecon -R /home
```


