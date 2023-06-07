#!/bin/bash
# (C) Copyright 2021-2023 By rjalil68
# ==================================================================
# Name        : VPN Script Quick Installation Script
# Description : This Script Is Setup for running other
#               quick Setup script from one click installation
# Created     : 16-05-2022 ( 16 May 2022 )
# OS Support  : Ubuntu & Debian
# Auther      : akubudakgerik
# WebSite     : https://akubudakgerik.com
# Github      : github.com/akubudakgerik
# License     : MIT License
# ==================================================================

# // Export Color & Information
export RED='\033[0;31m';
export GREEN='\033[0;32m';
export YELLOW='\033[0;33m';
export BLUE='\033[0;34m';
export PURPLE='\033[0;35m';
export CYAN='\033[0;36m';
export LIGHT='\033[0;37m';
export NC='\033[0m';

# // Export Banner Status Information
export ERROR="[${RED} ERROR ${NC}]";
export INFO="[${YELLOW} INFO ${NC}]";
export OKEY="[${GREEN} OKEY ${NC}]";
export PENDING="[${YELLOW} PENDING ${NC}]";
export SEND="[${YELLOW} SEND ${NC}]";
export RECEIVE="[${YELLOW} RECEIVE ${NC}]";
export RED_BG='\e[41m';

# // Start
grep -c -E "^Vless " "/etc/xray-mini/client.conf" > /etc/akubudakgerik/jumlah-akun-vless.db;
grep "^Vless " "/etc/xray-mini/client.conf" | awk '{print $2}'  > /etc/akubudakgerik/akun-vless.db;
totalaccounts=`cat /etc/akubudakgerik/akun-vless.db | wc -l`;
echo "Total Akun = $totalaccounts" > /etc/akubudakgerik/total-akun-vless.db;
for((i=1; i<=$totalaccounts; i++ ));
do
    # // Username Interval Counting
    username=$( head -n $i /etc/akubudakgerik/akun-vless.db | tail -n 1 );
    expired=$( grep "^Vless " "/etc/xray-mini/client.conf" | grep -w $username | head -n1 | awk '{print $3}' );

    # // Counting On Simple Algoritmatika
    now=`date -d "0 days" +"%Y-%m-%d"`;
    d1=$(date -d "$expired" +%s);
    d2=$(date -d "$now" +%s);
    sisa_hari=$(( (d1 - d2) / 86400 ));

# // Validate Use If Syntax
if [[ $sisa_hari -lt 1 ]]; then

    # // Removing Data From Server Configuration
    cp /etc/xray-mini/tls.json /etc/akubudakgerik/xray-mini-utils/tls-backup.json;
    cat /etc/akubudakgerik/xray-mini-utils/tls-backup.json | jq 'del(.inbounds[3].settings.clients[] | select(.email == "'${username}'"))' > /etc/akubudakgerik/xray-mini-cache.json;
    cat /etc/akubudakgerik/xray-mini-cache.json | jq 'del(.inbounds[6].settings.clients[] | select(.email == "'${username}'"))' > /etc/xray-mini/tls.json;
    cp /etc/xray-mini/nontls.json /etc/akubudakgerik/xray-mini-utils/nontls-backup.json;
    cat /etc/akubudakgerik/xray-mini-utils/nontls-backup.json | jq 'del(.inbounds[1].settings.clients[] | select(.email == "'${username}'"))' > /etc/xray-mini/nontls.json;
    rm -rf /etc/akubudakgerik/vless/${username};
    sed -i "/\b$client\b/d" /etc/xray-mini/client.conf;
    systemctl restart xray-mini@tls;
    systemctl restart xray-mini@nontls;

    # // Successfull Deleted Expired Client
    echo "Username : $username | Expired : $expired | Deleted $now" >> /etc/akubudakgerik/vless-expired-deleted.db;
    echo "Username : $username | Expired : $expired | Deleted $now";

else
    Skip="true";
fi

# // End Function
done