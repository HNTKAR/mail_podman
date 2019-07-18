iptables -N USER-MAIL-CHAIN
iptables -I USER-MAIL-CHAIN -j DROP -p tcp --dport 995
iptables -I USER-MAIL-CHAIN -j DROP -p tcp --dport 993
iptables -I USER-MAIL-CHAIN -j DROP -p tcp --dport 587
iptables -I USER-MAIL-CHAIN -j DROP -p tcp --dport 465
iptables -I USER-MAIL-CHAIN -j ACCEPT -m set --match-set white-list src -p tcp --dport 995
iptables -I USER-MAIL-CHAIN -j ACCEPT -m set --match-set white-list src -p tcp --dport 993
iptables -I USER-MAIL-CHAIN -j ACCEPT -m set --match-set white-list src -p tcp --dport 587
iptables -I USER-MAIL-CHAIN -j ACCEPT -m set --match-set white-list src -p tcp --dport 465
iptables -I DOCKER-USER -j USER-MAIL-CHAIN
