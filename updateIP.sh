#!/bin/sh

USE_PING=false

LOGG=/tmp/loopia-status

PATH=$PATH:/usr/sbin:/usr/bin:/bin:/sbin

username=$(nvram get ddns_username_5)
password=$(nvram get ddns_passwd_5)

hostname=$(nvram get ddns_hostname_5)

myip=`wget -O - http://dns.loopia.se/checkip/checkip.php 2> /dev/null | sed 's/.*Address: //' | sed 's/<.*//'`

if ! $USE_PING ; then
    resolved_ip=`nslookup $hostname | grep -A 1 -e "Name:.*$hostname" | tail -1 | awk '{print $3}'`
    if [ -z "$resolved_ip" ]; then
        # Fallback to using ping, as something failed
        USE_PING=true
    fi
fi

if $USE_PING ; then
    # The sed command removed everything but the contents of the first
    # parenthesis
    resolved_ip=$(ping -c 1 -w 1 $hostname | head -n 1 | sed 's/.*(\(.*\)).*/\1/')
fi

url="http://$username:$password@dns.loopia.se/XDynDNSServer/XDynDNS.php?system=custom&wildcard=nochg&hostname=$hostname&myip=$myip"

if [ "$resolved_ip" = "$myip" ]; then
    return
fi

tmpFile=/tmp/update-output

wget -O $tmpFile "$url" 2> /dev/null

cat $tmpFile >> $LOGG
rm $tmpFile

echo >> $LOGG
date >> $LOGG
echo "changed ip from $resolved_ip to $myip" >> $LOGG

