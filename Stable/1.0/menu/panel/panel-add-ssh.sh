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

# // Clear Data
clear;

# // String
user_tag="$1";
pass_tag="$3";
exp_tag="$5";
username="$2";
password="$4";
expired="$6";

if [[ $user_tag == "--user" ]]; then
    SKIP=TRUE;
else
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi
if [[ $pass_tag == "--pass" ]];  then
    SKIP=TRUE;
else
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi
if [[ $exp_tag == "--exp" ]]; then
    SKIP=true;
else
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi
if [[ $username == "" ]]; then
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi
if [[ $password == "" ]]; then
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi
if [[ $expired == "" ]]; then
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi

# // Input Data
Username=$username;
Password=$password;
Jumlah_Hari=$expired;

# // String For IP & Port
domain=$( cat /etc/akubudakgerik/domain.txt );
openssh=$( cat /etc/ssh/sshd_config | grep -E Port | head -n1 | awk '{print $2}' );
dropbear1=$( cat /etc/default/dropbear | grep -E DROPBEAR_PORT | sed 's/DROPBEAR_PORT//g' | sed 's/=//g' | sed 's/"//g' |  tr -d '\r' );
dropbear2=$( cat /etc/default/dropbear | grep -E DROPBEAR_EXTRA_ARGS | sed 's/DROPBEAR_EXTRA_ARGS//g' | sed 's/=//g' | sed 's/"//g' | awk '{print $2}' |  tr -d '\r' );
ovpn_tcp="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)";
ovpn_udp="$(netstat -nlpu | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)";
if [[ $ovpn_tcp == "" ]]; then
    ovpn_tcp="Eror";
fi
if [[ $ovpn_udp == "" ]]; then
    ovpn_udp="Eror";
fi
stunnel_dropbear=$( cat /etc/stunnel5/stunnel5.conf | grep -i accept | head -n 4 | cut -d= -f2 | sed 's/ //g' | tr '\n' ' ' | awk '{print $2}' | tr -d '\r' );
stunnel_ovpn_tcp=$( cat /etc/stunnel5/stunnel5.conf | grep -i accept | head -n 4 | cut -d= -f2 | sed 's/ //g' | tr '\n' ' ' | awk '{print $3}' | tr -d '\r' );
ssh_ssl2=$( cat /lib/systemd/system/sslh.service | grep -w ExecStart | head -n1 | awk '{print $6}' | sed 's/0.0.0.0//g' | sed 's/://g' | tr '\n' ' ' | tr -d '\r' | sed 's/ //g' );
ssh_nontls=$( cat /etc/akubudakgerik/ws-epro.conf | grep -i listen_port |  head -n 4 | cut -d= -f2 | sed 's/ //g' | sed 's/listen_port//g' | sed 's/://g' | tr '\n' ' ' | awk '{print $1}' | tr -d '\r' );
ssh_ssl=$( cat /etc/akubudakgerik/ws-epro.conf | grep -i listen_port |  head -n 4 | cut -d= -f2 | sed 's/ //g' | sed 's/listen_port//g' | sed 's/://g' | tr '\n' ' ' | awk '{print $2}' | tr -d '\r' );
squid1=$( cat /etc/squid/squid.conf | grep http_port | head -n 3 | cut -d= -f2 | awk '{print $2}' | sed 's/ //g' | tr '\n' ' ' | awk '{print $1}' );
squid2=$( cat /etc/squid/squid.conf | grep http_port | head -n 3 | cut -d= -f2 | awk '{print $2}' | sed 's/ //g' | tr '\n' ' ' | awk '{print $2}' );
ohp_1="$( cat /etc/systemd/system/ohp-mini-1.service | grep -i Port | awk '{print $3}' | head -n1)";
ohp_2="$( cat /etc/systemd/system/ohp-mini-2.service | grep -i Port | awk '{print $3}' | head -n1)";
ohp_3="$( cat /etc/systemd/system/ohp-mini-3.service | grep -i Port | awk '{print $3}' | head -n1)";
ohp_4="$( cat /etc/systemd/system/ohp-mini-4.service | grep -i Port | awk '{print $3}' | head -n1)";
udp_1=$( cat /etc/systemd/system/udp-mini-1.service | grep -i listen-addr | awk '{print $3}' | head -n1 | sed 's/127.0.0.1//g' | sed 's/://g' | tr -d '\r' );
udp_2=$( cat /etc/systemd/system/udp-mini-2.service | grep -i listen-addr | awk '{print $3}' | head -n1 | sed 's/127.0.0.1//g' | sed 's/://g' | tr -d '\r' );
udp_3=$( cat /etc/systemd/system/udp-mini-3.service | grep -i listen-addr | awk '{print $3}' | head -n1 | sed 's/127.0.0.1//g' | sed 's/://g' | tr -d '\r' );
today=`date -d "0 days" +"%Y-%m-%d"`;

# // Adding User To Server
useradd -e `date -d "$Jumlah_Hari days" +"%Y-%m-%d"` -s /bin/false -M $Username;
echo -e "$Password\n$Password\n"|passwd $Username &> /dev/null;
exp=`date -d "$Jumlah_Hari days" +"%Y-%m-%d"`;

# // Make Config Folder
mkdir -p /etc/akubudakgerik/ssh/;
mkdir -p /etc/akubudakgerik/ssh/${Username}/;

# // Success
clear;
echo -e "Create From Panel | SSH" | tee -a /etc/akubudakgerik/shadowsocks/${Username}/config.log;
echo -e "===============================" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " IP Address       = "'```'"${IP_NYA}"'```'"" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Hostname         = "'```'"${domain}"'```'"" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Username         = "'```'"${Username}"'```'"" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Password         = "'```'"${Password}"'```'"" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e "===============================" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " OpenSSH          = ${openssh}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Dropbear         = ${dropbear1},${dropbear2}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Stunnel          = ${ssh_ssl2},${stunnel_dropbear}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " SSH WS CDN       = ${ssh_ssl2}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " SSH WS NTLS      = ${ssh_nontls}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " SSH WS TLS       = ${ssh_ssl}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " OVPN TCP         = ${ovpn_tcp}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " OVPN UDP         = ${ovpn_udp}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " OVPN SSL         = ${stunnel_ovpn_tcp}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Squid Proxy 1    = ${squid1}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Squid Proxy 2    = ${squid2}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " OHP OpenSSH      = ${ohp_1}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " OHP Dropbear     = ${ohp_2}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " OHP OpenVPN      = ${ohp_3}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " OHP Universal    = ${ohp_4}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " BadVPN UDP 1     = ${udp_1}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " BadVPN UDP 2     = ${udp_2}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " BadVPN UDP 3     = ${udp_3}" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e "===============================" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Payload WebSocket NonTLS" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " "' ```'"GET / HTTP/1.1[crlf]Host: ${DOMAIN}[crlf]Upgrade: websocket[crlf][crlf]"'```'"" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e "===============================" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Payload WebSocket TLS" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " "' ```'"GET wss://example.com [protocol][crlf]Host: ${DOMAIN}[crlf]Upgrade: websocket[crlf][crlf]"'```'"" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e "===============================" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Link OVPN TCP    = http://${IP}:85/tcp.ovpn" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Link OVPN UDP    = http://${IP}:85/udp.ovpn" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Link SSL TCP     = http://${IP}:85/ssl-tcp.ovpn" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Link OVPN CONFIG = http://${IP}:85/all.zip" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e "===============================" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Created = $today" | tee -a /etc/akubudakgerik/ssh/${Username}/config.log;
echo -e " Expired = $exp";
echo -e "===============================";