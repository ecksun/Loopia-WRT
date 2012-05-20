#!/bin/sh

PATH=$PATH:/usr/sbin:/usr/bin:/bin:/sbin

username=$(nvram get ddns_username_5)
password=$(nvram get ddns_passwd_5)

hostname=$(nvram get ddns_hostname_5)

myip=`wget -O - http://dns.loopia.se/checkip/checkip.php 2> /dev/null | sed 's/.*Address: //' | sed 's/<.*//'`
resolved_ip=`nslookup $hostname | grep -A 1 -e "Name:.*$hostname" | tail -1 | awk '{print $3}'`


url="http://$username:$password@dns.loopia.se/XDynDNSServer/XDynDNS.php?system=custom&wildcard=nochg&hostname=$hostname&myip=$myip"

if [ "$resolved_ip" = "$myip" ]; then
    return
fi

wget -O /tmp/loopia-status "$url" 2> /dev/null

echo >> /tmp/loopia-status
date >> /tmp/loopia-status
echo "changed ip from $resolved_ip to $myip" >> /tmp/loopia-status

