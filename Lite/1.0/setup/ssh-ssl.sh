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
		echo -e " ${ERROR} Please run this script as root user";
		exit 1;
fi

# // Checking Requirement Installed / No
if ! which jq > /dev/null; then
    rm -f /root/ssh-ssl.sh;
    rm -f /root/requirement.sh;
    rm -f /root/nginx.sh;
    rm -f /root/setup.sh;
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
    rm -f /root/ssh-ssl.sh;
    rm -f /root/requirement.sh;
    rm -f /root/nginx.sh;
    rm -f /root/setup.sh;
    clear;
    echo -e "${ERROR} Your IP Got Blacklisted";
    exit 1;
fi

# // Checking License Key
if [[ -r /etc/akubudakgerik/license-key.wd21 ]]; then
    SKIP=true;
else
    rm -f /root/ssh-ssl.sh;
    rm -f /root/requirement.sh;
    rm -f /root/nginx.sh;
    rm -f /root/setup.sh;
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
    rm -f /root/ssh-ssl.sh;
    rm -f /root/requirement.sh;
    rm -f /root/nginx.sh;
    rm -f /root/setup.sh;
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
export PELANGGAN_KE$( echo ${API_REQ_NYA} | jq -r '.id' );
export TYPE=$( echo ${API_REQ_NYA} | jq -r '.id' );
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

# // Validate License Key
if [[ ${LCN_KEY} == $LICENSE_KEY ]]; then
    SKIP=true;
else
    rm -f /root/ssh-ssl.sh;
    rm -f /root/requirement.sh;
    rm -f /root/nginx.sh;
    rm -f /root/setup.sh;
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
        rm -f /root/ssh-ssl.sh;
        rm -f /root/requirement.sh;
        rm -f /root/nginx.sh;
        rm -f /root/setup.sh;
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
    rm -f /root/ssh-ssl.sh;
    rm -f /root/requirement.sh
    rm -f /root/nginx.sh;
    rm -f /root/setup.sh;
    clear;
    echo -e "${ERROR} Your IP Not Registered";
    exit 1;
fi

# // Validate Your License is active or no
if [[ $STATUS_LCN == "active" ]]; then
    SKIP=true;
else
    rm -f /root/ssh-ssl.sh;
    rm -f /root/requirement.sh
    rm -f /root/nginx.sh;
    rm -f /root/setup.sh;
    clear;
    echo -e "${ERROR} Your License key not active";
    exit 1;
fi

# // Replace Pam.d password common
wget -q -O /etc/pam.d/common-password "https://rjalil68/vpn-script/Resource/Config/password";
chmod +x /etc/pam.d/common-password;

# // Installing Dropbear
wget -q -O /etc/ssh/sshd_config "https://rjalil68/vpn-script/Resource/Config/sshd_config";
/etc/init.d/ssh restart;
apt install dropbear -y;
wget -q -O /etc/default/dropbear "https://rjalil68/vpn-script/Resource/Config/dropbear_conf";
chmod +x /etc/default/dropbear;
echo "/bin/false" >> /etc/shells;
echo "/usr/sbin/nologin" >> /etc/shells;
wget -q -O /etc/akubudakgerik/banner.txt "https://rjalil68/vpn-script/Resource/Config/banner.txt";
/etc/init.d/dropbear restart;

# // Installing Stunnel5
if [[ -f /etc/systemd/system/stunnel5.service ]]; then
    systemctl disable stunnel5 > /dev/null 2>&1;
    systemctl stop stunnel5 > /dev/null 2>&1;
    /etc/init.d/stunnel5 stop > /dev/null 2>&1;
fi
cd /root/;
wget -q -O stunnel5.zip "https://rjalil68/vpn-script/Resource/Core/stunnel5.zip";
unzip -o stunnel5.zip > /dev/null 2>&1;
cd /root/stunnel;
chmod +x configure && ./configure && make && make install;
cd /root;
rm -r -f stunnel;
rm -f stunnel5.zip;
mkdir -p /etc/stunnel5;
chmod 644 /etc/stunnel5;
wget -q -O /etc/stunnel5/stunnel5.conf "https://rjalil68/vpn-script/Resource/Config/stunnel5_conf";
wget -q -O /etc/stunnel5/stunnel5.pem "https://rjalil68/vpn-script/Data/stunnel_cert";
wget -q -O /etc/systemd/system/stunnel5.service "https://rjalil68/vpn-script/Resource/Service/stunnel5_service";
wget -q -O /etc/init.d/stunnel5 "https://rjalil68/vpn-script/Resource/Service/stunnel5_init";
chmod 600 /etc/stunnel5/stunnel5.pem;
chmod +x /etc/init.d/stunnel5;
cp /usr/local/bin/stunnel /usr/local/akubudakgerik/stunnel5;
rm -r -f /usr/local/share/doc/stunnel/;
rm -r -f /usr/local/etc/stunnel/;
rm -f /usr/local/bin/stunnel;
rm -f /usr/local/bin/stunnel3;
rm -f /usr/local/bin/stunnel4;
rm -f /usr/local/bin/stunnel5;
systemctl enable stunnel5;
systemctl start stunnel5;
/etc/init.d/stunnel5 restart;

# // Installing Ws-ePro
wget -q -O /usr/local/akubudakgerik/ws-epro "https://rjalil68/vpn-script/Resource/Core/ws-epro";
chmod +x /usr/local/akubudakgerik/ws-epro;
wget -q -O /etc/systemd/system/ws-epro.service "https://rjalil68/vpn-script/Resource/Service/ws-epro_service";
chmod +x /etc/systemd/system/ws-epro.service;
wget -q -O /etc/akubudakgerik/ws-epro.conf "https://rjalil68/vpn-script/Resource/Config/ws-epro_conf";
chmod 644 /etc/akubudakgerik/ws-epro.conf;
systemctl enable ws-epro;
systemctl start ws-epro;
systemctl restart ws-epro;

# // Instaling SSLH
apt install sslh -y;
wget -q -O /lib/systemd/system/sslh.service "https://rjalil68/vpn-script/Resource/Service/sslh_service"
systemctl daemon-reload
systemctl disable sslh > /dev/null 2>&1;
systemctl stop sslh > /dev/null 2>&1;
systemctl enable sslh;
systemctl start sslh;
systemctl restart sslh;

# // Remove not used file
rm -f /root/ssh-ssl.sh;

# // Successfull
clear;
echo -e "${OKEY} Successfull Installed Stunnel & Dropbear";