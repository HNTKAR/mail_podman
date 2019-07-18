logfile=/var/log/docker_log/maillog
`:`>>black_list_log
`:`>>black_list
chmod 777 black_list_log
cat $logfile | grep  SASL|sed  -e 's/.*\[//g' -e 's/\].*'//g >>black_list_log
cat black_list_log | awk  'a[$0]++ == 10'>>black_list

#iptables -N BLACK-CHAIN

