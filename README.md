# mail server Container

## **設定ファイル**

```
###mail###
ssl_domain:example.com
hostname:example.com,example.org
user:email1:password1
user:email2:password2
user:email3:password3
relay:relay_domain1:relay_destination1
relay:relay_domain2:relay_destination2
replssl_domain:example.net
replpassword:replication_server's_cyrus_password
```

## **コンテナの起動**
```shell
sudo firewall-cmd --add-forward-port=port=25:proto=tcp:toport=1025 --permanent
sudo firewall-cmd --add-forward-port=port=143:proto=tcp:toport=10143 --permanent
sudo firewall-cmd --add-forward-port=port=587:proto=tcp:toport=10587 --permanent
sudo firewall-cmd --add-forward-port=port=993:proto=tcp:toport=10993 --permanent
sudo firewall-cmd --reload
sudo mkdir -p -m 777 /home/podman/mail_pod/mta_spool /home/podman/mail_pod/mta_conf /home/podman/mail_pod/mta_log /home/podman/mail_pod/imap_data /home/podman/mail_pod/imap_spool /home/podman/mail_pod/imap_conf /home/podman/mail_pod/imap_log 
./script.sh
#master
podman pod create --replace=true -p 1025:25 -p 10143:143 -p 10587:587 -p 10993:993 -n mail_pod --net slirp4netns:port_handler=slirp4netns
podman run --replace=true -td --pod mail_pod -v /home/podman/mail_pod/mta_spool:/spool -v /home/podman/mail_pod/mta_conf:/conf -v /home/podman/mail_pod/mta_log:/log --name postfix-master postfix-master
podman run --replace=true -td --pod mail_pod -v /home/podman/mail_pod/imap_data:/data -v /home/podman/mail_pod/imap_spool:/spool -v /home/podman/mail_pod/imap_conf:/conf -v /home/podman/mail_pod/imap_log:/log --name cyrus-master cyrus-master
#slave
podman pod create --replace=true -p 1025:25 -p 10143:143 -p 10587:587 -p 10993:993 -n mail_pod --net slirp4netns:port_handler=slirp4netns
podman run --replace=true -td --pod mail_pod -v /home/podman/mail_pod/mta_spool:/spool -v /home/podman/mail_pod/mta_conf:/conf -v /home/podman/mail_pod/mta_log:/log --name postfix-slave postfix-slave
podman run --replace=true -td --pod mail_pod -v /home/podman/mail_pod/imap_data:/data -v /home/podman/mail_pod/imap_spool:/spool -v /home/podman/mail_pod/imap_conf:/conf -v /home/podman/mail_pod/imap_log:/log --name cyrus-slave cyrus-slave
```
## **ファイルおよびフォルダ**
<!--
 samba  
> * /home/podman/file_pod/local_conf/smb.conf  
>>  smbd用基本設定ファイル ( default : /etc/samba/smb.conf )
> 
> * /home/podman/file_pod/local_conf/private/  
>> ユーザー管理データベース ( default : /var/lib/samba/private/ )  
>> 手動で新規ユーザーを追加する場合はコンテナ内で以下のコマンドを使用する
>> ```
>> user add USER_NAME
>> pdbedit -a -u USER_NAME -s /conf/smb.conf
>> ```  
>
> * /home/podman/file_pod/local_log/  
>> 各種ログ ( default : /var/log/ )

> vsftp
> * /home/podman/file_pod/global_conf/vsftpd.conf  
>> vsftpd用基本設定ファイル  ( default /etc/vsftpd/vsftpd.conf )  
> 
> * /home/podman/file_pod/global_conf/vsftp_user_conf/USER_NAME  
>> ユーザー個別設定ファイル ( default : /etc/vsftpd/userconf/USER_NAME )  
>> ここに書かれた設定がユーザーごとに適用される  
>> /etc/vsftpd/userconf/USER1 の例
>> ```
>> local_root=/data/user1_dir
>> write_enable=YES
>> ```
> * /home/podman/file_pod/global_conf/vsftpd.chroot_list  
>> 非chrootユーザー設定ファイル ( default : /etc/vsftpd/vsftpd.chroot_list )  
>> ここに書かれたユーザーはchrootの影響を受けない  
>> vsftpd.chroot_list の例
>> ``` 
>> USER1
>> USER2
>> ```
> * /home/podman/file_pod/global_log/  
>> 各種ログ ( default : /var/log/ )
-->

### 自動起動の設定
```
mkdir -p $HOME/.config/systemd/user/
podman generate systemd -f -n --new --restart-policy=always mail_pod >tmp.service
systemctl --user start pod-mail_pod
cat tmp.service | \
xargs -I {} \cp {} -frp $HOME/.config/systemd/user
cat tmp.service | \
xargs -I {} systemctl --user enable {}
```

### 自動起動解除
```
cat tmp.service | \
xargs -I {} systemctl --user disable {}
```
