# mail server Container

## **設定ファイル**

```
###mail###
ssl_domain:example.com
mail_domain:example.com,example.org
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
podman pod create --replace=true -p 1025:25 -p 10143:143 -p 10587:587 -p 10993:993 -n mail_pod --net slirp4netns:port_handler=slirp4netns
#master
podman run --replace=true -td --pod mail_pod -v /home/podman/mail_pod/mta_spool:/spool -v /home/podman/mail_pod/mta_conf:/conf -v /home/podman/mail_pod/mta_log:/log --name postfix-master postfix-master
podman run --replace=true -td --pod mail_pod -v /home/podman/mail_pod/imap_data:/data -v /home/podman/mail_pod/imap_spool:/spool -v /home/podman/mail_pod/imap_conf:/conf -v /home/podman/mail_pod/imap_log:/log --name cyrus-master cyrus-master
#slave
podman run --replace=true -td --pod mail_pod -v /home/podman/mail_pod/mta_spool:/spool -v /home/podman/mail_pod/mta_conf:/conf -v /home/podman/mail_pod/mta_log:/log --name postfix-slave postfix-slave
podman run --replace=true -td --pod mail_pod -v /home/podman/mail_pod/imap_data:/data -v /home/podman/mail_pod/imap_spool:/spool -v /home/podman/mail_pod/imap_conf:/conf -v /home/podman/mail_pod/imap_log:/log --name cyrus-replica cyrus-replica
```
## **ファイルおよびフォルダ**
postfix  
<details><summary>/home/podman/mail_pod/mta_spool/</summary><div>  

>  メールキュー ( default : /var/spool/postfix/ )  
>  未配送のメールがここに溜まる  

</div></details> 

<details><summary>/home/podman/mail_pod/mta_conf/main.cf</summary><div>  

>  postfix用基本設定ファイル ( default : /etc/postfix/main.cf )

</div></details> 
<details><summary>/home/podman/mail_pod/mta_conf/master.cf</summary><div>  

>  postfix用プロセス設定ファイル ( default : /etc/postfix/master.cf )

</div></details> 

<details><summary>/home/podman/mail_pod/mta_conf/aliases(.db)</summary><div>  

>  メールの転送設定ファイル ( default : /etc/aliases(.db) )
>  A@example.com に届いたメールを B@example.com と C@example.org に転送する場合は以下のように記載し再起動
> ```
> A@example.com: B@example.com, C@example.org
> ```
>  aliases.db は run-postfix.sh内の `postalias` コマンドによって生成される

</div></details> 

<details><summary>/home/podman/mail_pod/mta_conf/transport(.db)</summary><div>  

>  メールのリレー設定ファイル ( default : /etc/postfix/transport(.db) )
>  example.com 宛のメールを example.org にリレーする場合は以下のように記載し再起動
>  ```
>  example.com smtp:example.org
>  ```
>  transport.db は run-postfix.sh内の `postmap` コマンドによって生成される

</div></details> 

<details><summary>/home/podman/mail_pod/mta_conf/vmailbox(.db)</summary><div>  

>  メールの配送設定ファイル ( default : /etc/postfix/vmailbox(.db) )
>  A@example.com 宛のメールを cyrus-imapの A@example.com にリレーする場合は以下のように記載し再起動
>  ```
>  A@example.com A@example.com
>  ```
>  vmailbox.db は run-postfix.sh内の `postmap` コマンドによって生成される

</div></details> 

<details><summary>/home/podman/mail_pod/mta_conf/sasldb2</summary><div>  

>  ユーザー管理データベース ( default : /etc/sasldb2 )  

</div></details> 

<details><summary>/home/podman/file_pod/mta_log/</summary><div>

> 各種ログ ( default : /var/log/ )

</div></details>

cyrus-imapd  
<details><summary>/home/podman/mail_pod/imap_spool/</summary><div>  

>  メールデータ ( default : /var/spool/imap/ )  
>  メール本体のデータがここに溜まる  

</div></details> 
<details><summary>/home/podman/mail_pod/imap_data/</summary><div>  

>  メールデータベース ( default : /var/lib/imap/ )  
>  メール格納場所のデータベース  

</div></details> 

<details><summary>/home/podman/mail_pod/imap_conf/imapd.conf</summary><div>  

>  cyrus-imapd用基本設定ファイル ( default : /etc/imapd.conf )

</div></details> 
<details><summary>/home/podman/mail_pod/mail_conf/cyrus.conf</summary><div>  

>  cyrus-imapd用プロセス設定ファイル ( default : /etc/postfix/cyrus.cf )

</div></details> 

<details><summary>/home/podman/mail_pod/imap_conf/sasldb2</summary><div>  

>  ユーザー管理データベース ( default : /etc/sasldb2 )  

</div></details> 

<details><summary>/home/podman/mail_pod/imap_log/</summary><div>

> 各種ログ ( default : /var/log/ )

</div></details>  

<br>

### 手動で新規ユーザーを追加する場合はコンテナ内で以下のコマンドを使用する  

> cyrus-master  
> ```
> saslpasswd2 -c -f /conf/sasldb2 -u USER_DOMAIN USER_NAME'
> ```
> postfix-master  
> ```
> saslpasswd2 -c -f /conf/sasldb2 -u USER_DOMAIN USER_NAME'
> echo "USERNAME@USER_DOMAIN USERNAME@USER_DOMAIN">> /conf/vmailbox
> postmap /conf/vmailbox
> ```  
> postfix-replica
> ```
> echo "USER_DOMAIN smtp:USER_DOMAIN">> /conf/transport
> postmap /conf/transport
> ```

### 自動起動の設定
> ```
> mkdir -p $HOME/.config/systemd/user/
> podman generate systemd -f -n --new --restart-policy=always mail_pod >tmp.service
> systemctl --user start pod-mail_pod
> cat tmp.service | \
> xargs -I {} \cp {} -frp $HOME/.config/systemd/user
> cat tmp.service | \
> xargs -I {} systemctl --user enable {}
> ```

### 自動起動解除
> ```
> cat tmp.service | \
> xargs -I {} systemctl --user disable {}
> ```
