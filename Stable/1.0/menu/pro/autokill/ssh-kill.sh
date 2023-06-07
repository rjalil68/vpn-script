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

# // Export Align
export BOLD="\e[1m";
export WARNING="${RED}\e[5m";
export UNDERLINE="\e[4m";

# // Export OS Information
export OS_ID=$( cat /etc/os-release | grep -w ID | sed 's/ID//g' | sed 's/=//g' | sed 's/ //g' );
export OS_VERSION=$( cat /etc/os-release | grep -w VERSION_ID | sed 's/VERSION_ID//g' | sed 's/=//g' | sed 's/ //g' | sed 's/"//g' );
export OS_NAME=$( cat /etc/os-release | grep -w PRETTY_NAME | sed 's/PRETTY_NAME//g' | sed 's/=//g' | sed 's/"//g' );
export OS_KERNEL=$( uname -r );
export OS_ARCH=$( uname -m );

# // String For Helping Installation
export VERSION="1.0";
export EDITION="Stable";
export AUTHER="akubudakgerik";
export ROOT_DIRECTORY="/etc/akubudakgerik";
export CORE_DIRECTORY="/usr/local/akubudakgerik";
export SERVICE_DIRECTORY="/etc/systemd/system";
export SCRIPT_SETUP_URL="https://rjalil68/vpn-script";
export REPO_URL="https://repository.akubudakgerik.com";

# // Checking Your Running Or Root or no
if [[ "${EUID}" -ne 0 ]]; then
        clear;
		echo -e " ${ERROR} Please run this script as root user";
		exit 1;
fi

# // Checking Requirement Installed / No
if ! which jq > /dev/null; then
    clear;
    echo -e "${ERROR} JQ Packages Not installed";
    exit 1;
fi

# // Exporting Network Information
wget -qO- --inet4-only 'https://rjalil68/vpn-script/get-ip_sh' | bash;
source /root/ip-detail.txt;
export IP_NYA="$IP";
export ASN_NYA="$ASN";
export ISP_NYA="$ISP";
export REGION_NYA="$REGION";
export CITY_NYA="$CITY";
export COUNTRY_NYA="$COUNTRY";
export TIME_NYA="$TIMEZONE";

# // Check Blacklist
export CHK_BLACKLIST=$( wget -qO- --inet4-only 'https://api.akubudakgerik.com/vpn-script/blacklist.php?ip='"${IP_NYA}"'' );
if [[ $( echo $CHK_BLACKLIST | jq -r '.respon_code' ) == "127" ]]; then
    SKIP=true;
else
    clear;
    echo -e "${ERROR} Your IP Got Blacklisted";
    exit 1;
fi

# // Checking License Key
if [[ -r /etc/akubudakgerik/license-key.wd21 ]]; then
    SKIP=true;
else
    clear;
    echo -e "${ERROR} Having error, all is corrupt";
    exit 1;
fi
LCN_KEY=$( cat /etc/akubudakgerik/license-key.wd21 | awk '{print $3}' | sed 's/ //g' );
if [[ $LCN_KEY == "" ]]; then
    clear;
    echo -e "${ERROR} Having Error in your License key";
    exit 1;
fi

export API_REQ_NYA=$( wget -qO- --inet4-only 'https://api.akubudakgerik.com/vpn-script/secret/chk-rnn.php?scrty_key=61716199-7c73-4945-9918-c41133d4c94e&ip_addr='"${IP_NYA}"'&lcn_key='"${LCN_KEY}"'' );
if [[ $( echo ${API_REQ_NYA} | jq -r '.respon_code' ) == "104" ]]; then
    SKIP=true;
else
    clear;
    echo -e "${ERROR} Script Server Refused Connection";
    exit 1;
fi

# // Rending Your License data from json
export RESPON_CODE=$( echo ${API_REQ_NYA} | jq -r '.respon_code' );
export IP=$( echo ${API_REQ_NYA} | jq -r '.ip' );
export STATUS_IP=$( echo ${API_REQ_NYA} | jq -r '.status2' );
export STATUS_LCN=$( echo ${API_REQ_NYA} | jq -r '.status' );
export LICENSE_KEY=$( echo ${API_REQ_NYA} | jq -r '.license' );
export PELANGGAN_KE=$( echo ${API_REQ_NYA} | jq -r '.id' );
export TYPE=$( echo ${API_REQ_NYA} | jq -r '.type' );
export COUNT=$( echo ${API_REQ_NYA} | jq -r '.count' );
export LIMIT=$( echo ${API_REQ_NYA} | jq -r '.limit' );
export CREATED=$( echo ${API_REQ_NYA} | jq -r '.created' );
export EXPIRED=$( echo ${API_REQ_NYA} | jq -r '.expired' );
export UNLIMITED=$( echo ${API_REQ_NYA} | jq -r '.unlimited' );
export LIFETIME=$( echo ${API_REQ_NYA} | jq -r '.lifetime' );
export STABLE=$( echo ${API_REQ_NYA} | jq -r '.stable' );
export BETA=$( echo ${API_REQ_NYA} | jq -r '.beta' );
export FULL=$( echo ${API_REQ_NYA} | jq -r '.full' );
export LITE=$( echo ${API_REQ_NYA} | jq -r '.lite' );
export NAME=$( echo ${API_REQ_NYA} | jq -r '.name' );

# // Validate License Key
if [[ ${LCN_KEY} == $LICENSE_KEY ]]; then
    SKIP=true;
else
    clear;
    echo -e "${ERROR} Your License Key Invalid";
    exit 1;
fi

# // Validate Expired
if [[ ${LIFETIME} == "true" ]]; then
    SKIP=true;
else
    waktu_sekarang=$(date -d "0 days" +"%Y-%m-%d");
    expired_date="$EXPIRED";
    now_in_s=$(date -d "$waktu_sekarang" +%s);
    exp_in_s=$(date -d "$expired_date" +%s);
    days_left=$(( ($exp_in_s - $now_in_s) / 86400 ));
    if [[ $days_left -lt 0 ]]; then
        clear;
        echo -e "${ERROR} Your License Key expired";
        exit 1;
    else
        export DAYS_LEFT=${days_left};
    fi
fi

# // Validate Your IP is activated or no
if [[ $STATUS_IP == "active" ]]; then
    SKIP=true;
else
    clear;
    echo -e "${ERROR} Your IP Not Registered";
    exit 1;
fi

# // Validate Your License is active or no
if [[ $STATUS_LCN == "active" ]]; then
    SKIP=true;
else
    clear;
    echo -e "${ERROR} Your License key not active";
    exit 1;
fi

# // For Pro Only
if [[ $TYPE == "Pro" ]]; then
    SKIP=true;
else
    clear;
    echo -e "${ERROR} Autokill avaiable only in Pro License";
    exit 1;
fi

# // Check Your SSH Log User
if [ -e "/var/log/auth.log" ]; then
        OS=1;
        LOG="/var/log/auth.log";
fi
if [ -e "/var/log/secure" ]; then
        OS=2;
        LOG="/var/log/secure";
fi

# // Validating SSH Log is in where ( ssh / sshd )
if [ $OS -eq 1 ]; then
    # // Restart SSH
	service ssh restart > /dev/null 2>&1;
fi
if [ $OS -eq 2 ]; then
    # // Restart SSHD
	service sshd restart > /dev/null 2>&1;
fi

# // Restart Dropbear
service dropbear restart > /dev/null 2>&1;

# // Inputing Max Login				
source /etc/akubudakgerik/autokill.conf;
if [[ $ENABLED == "0" ]]; then
    clear;
    echo -e "$(date) Autokill is disabled";
    exit 1;
elif [[ $ENABLED == "1" ]]; then
    ENABLECOY=true;
else
    clear;
    echo -e "$(date) Configuration not found";
    exit 1;
fi

MAX=$SSH;
if [[ $MAX == "" ]]; then
        echo -e "$(date) SSH Autokill No Setuped.";
fi

# // Start
echo "$(date) Autokill SSH MultiLogin for akubudakgerik Script V1.0 Stable";
echo "$(date) Coded by akubudakgerik ( Version 1.0 Beta )";
echo "$(date) Starting Vmess Autokill Service.";

# // Start Daemon
while true; do
sleep 30
cat /etc/passwd | grep "/home/" | cut -d":" -f1 > /etc/akubudakgerik/ssh-user.db;
username1=( `cat "/etc/akubudakgerik/ssh-user.db" `);
i="0";
for user in "${username1[@]}"
do
    username[$i]=`echo $user | sed 's/'\''//g'`;
    jumlah[$i]=0;
    i=$i+1;
done
cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /etc/akubudakgerik/ssh-autokill-cache.db;
proc=( `ps aux | grep -i dropbear | awk '{print $2}'`);
for PID in "${proc[@]}"
do
cat /etc/akubudakgerik/ssh-autokill-cache.db | grep "dropbear\[$PID\]" > /etc/akubudakgerik/autokill-ssh-cache1.db;
NUM=`cat /etc/akubudakgerik/autokill-ssh-cache1.db | wc -l`;
USER=`cat /etc/akubudakgerik/autokill-ssh-cache1.db | awk '{print $10}' | sed 's/'\''//g'`;
IP=`cat /etc/akubudakgerik/autokill-ssh-cache1.db | awk '{print $12}'`;
if [ $NUM -eq 1 ]; then
i=0;
for user1 in "${username[@]}"
do
    if [ "$USER" == "$user1" ]; then
        jumlah[$i]=`expr ${jumlah[$i]} + 1`;
        pid[$i]="${pid[$i]} $PID";
    fi
    i=$i+1;
done
fi
done
cat $LOG | grep -i sshd | grep -i "Accepted password for" > /etc/akubudakgerik/ssh-autokill-cache.db;
data=( `ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'`);
for PID in "${data[@]}"
do
cat /etc/akubudakgerik/ssh-autokill-cache.db | grep "sshd\[$PID\]" > /etc/akubudakgerik/autokill-ssh-cache1.db;
NUM=`cat /etc/akubudakgerik/autokill-ssh-cache1.db | wc -l`;
USER=`cat /etc/akubudakgerik/autokill-ssh-cache1.db | awk '{print $9}'`;
IP=`cat /etc/akubudakgerik/autokill-ssh-cache1.db | awk '{print $11}'`;
if [ $NUM -eq 1 ]; then
i=0;
for user1 in "${username[@]}"
do
    if [ "$USER" == "$user1" ]; then
        jumlah[$i]=`expr ${jumlah[$i]} + 1`;
        pid[$i]="${pid[$i]} $PID";
    fi
    i=$i+1;
done
fi
done
j="0";
for i in ${!username[*]}
do
    if [ ${jumlah[$i]} -gt $MAX ]; then
        date=`date +"%X"`;
        echo "SSH - $(date) - ${username[$i]} - Multi Login Detected - Killed at ${date}";
        echo "SSH - $(date) - ${username[$i]} - Multi Login Detected - Killed at ${date}" >> /etc/akubudakgerik/autokill.log;
        kill ${pid[$i]};
        pid[$i]="";
        j=`expr $j + 1`;
    fi
done
if [ $j -gt 0 ]; then
    if [ $OS -eq 1 ]; then
        service ssh restart > /dev/null 2>&1;
    fi
    if [ $OS -eq 2 ]; then
        service sshd restart > /dev/null 2>&1;
    fi
        service dropbear restart > /dev/null 2>&1;
        j=0;
fi
done