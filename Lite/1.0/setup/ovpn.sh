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
    rm -f /root/ovpn.sh;
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
    rm -f /root/ovpn.sh;
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
    rm -f /root/ovpn.sh;
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
    rm -f /root/ovpn.sh;
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
    rm -f /root/ovpn.sh;
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
        rm -f /root/ovpn.sh;
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
    rm -f /root/ovpn.sh;
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
    rm -f /root/ovpn.sh;
    rm -f /root/ssh-ssl.sh;
    rm -f /root/requirement.sh
    rm -f /root/nginx.sh;
    rm -f /root/setup.sh;
    clear;
    echo -e "${ERROR} Your License key not active";
    exit 1;
fi

# // Take VPS IP & Network Interface
MYIP2="s/xxxxxxxxx/$IP_NYA/g";
NET=$(ip route show default | awk '{print $5}');

# // Installing Update
apt update -y;
apt upgrade -y;
apt dist-upgrade -y;
apt autoremove -y;
apt clean -y;

# // Installing Requirement Tools
apt install openvpn unzip -y;
apt install openssl iptables iptables-persistent -y;

# // Remove OpenVPN Directory & Recreate
rm -r -f /etc/openvpn;
mkdir -p /etc/openvpn;

# // Enter To OpenVPN Main Folder
cd /etc/openvpn/;
wget -q -O cert.zip "https://rjalil68/vpn-script/Data/ovpn_cert.zip";
unzip -o cert.zip;
rm -f cert.zip;
mkdir -p config;
rm -r -f server;
rm -r -f client;

# // Chwon Root Directory Data
chown -R root:root /etc/openvpn/;

# // Copying OpenVPN Plugin Auth To /usr/lib/openvpn
mkdir -p /usr/lib/openvpn/;
cp /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so /usr/lib/openvpn/openvpn-plugin-auth-pam.so;

# // Enable AUTOSTART For OpenVPN
sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn;

# // Downloading OpenVPN Server Config
wget -q -O /etc/openvpn/tcp.conf "https://rjalil68/vpn-script/Resource/OpenVPN/tcp_conf";
wget -q -O /etc/openvpn/udp.conf "https://rjalil68/vpn-script/Resource/OpenVPN/udp_conf";

# // Remove The OpenVPN Service & Replace New OpenVPN Service
rm -f /lib/systemd/system/openvpn-server@.service;
wget -q -O /etc/systemd/system/openvpn@.service "https://rjalil68/vpn-script/Resource/Service/openvpn_service";

# Enable OpenVPN & Start OpenVPN
systemctl daemon-reload;
systemctl stop openvpn@tcp;
systemctl stop openvpn@udp;
systemctl disable openvpn@tcp;
systemctl disable openvpn@udp;
systemctl enable openvpn@tcp;
systemctl enable openvpn@udp;
systemctl start openvpn@tcp;
systemctl start openvpn@udp;

# // Checking OpenVPN TCP Statuss
echo -e "${YELLOW}==============================${NC}";
if [[ $( systemctl status openvpn@tcp | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' ) == "running" ]]; then
echo -e "${OKEY} OpenVPN TCP Running !";
else
echo -e "${EROR} OpenVPN TCP Has Been Stopped !";
fi

# // Checking OpenVPN UDP Statuss
if [[ $( systemctl status openvpn@udp | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' ) == "running" ]]; then
echo -e "${OKEY} OpenVPN UDP Running !";
else
echo -e "${EROR} OpenVPN UDP Has Been Stopped !";
fi
echo -e "${YELLOW}==============================${NC}"
echo -e "${INFO} Enabling OpenVPN Daemon Service.";
echo "Starting Daemon Service For OpenVPN.";
echo "Successfull Started Daemon Service For OpenVPN.";

# // Generating TCP To Cache Directory
wget -q -O /etc/openvpn/config/tcp.ovpn "https://rjalil68/vpn-script/Resource/OpenVPN/tcp_client";
wget -q -O /etc/openvpn/config/udp.ovpn "https://rjalil68/vpn-script/Resource/OpenVPN/udp_client";
wget -q -O /etc/openvpn/config/ssl.ovpn "https://rjalil68/vpn-script/Resource/OpenVPN/ssl_client";

# // Adding IP Address To OpenVPN Client Configuration
sed -i $MYIP2 /etc/openvpn/config/tcp.ovpn;
sed -i $MYIP2 /etc/openvpn/config/udp.ovpn;
sed -i $MYIP2 /etc/openvpn/config/ssl.ovpn;

# // Input Certificate to TCP Client Config
echo '<ca>' >> /etc/openvpn/config/tcp.ovpn;
cat /etc/openvpn/ca.crt >> /etc/openvpn/config/tcp.ovpn;
echo '</ca>' >> /etc/openvpn/config/tcp.ovpn;

# // Input Certificate to UDP Client Config
echo '<ca>' >> /etc/openvpn/config/udp.ovpn;
cat /etc/openvpn/ca.crt >> /etc/openvpn/config/udp.ovpn;
echo '</ca>' >> /etc/openvpn/config/udp.ovpn;

# // Input Certificate to SSL-TCP Client Config
echo '<ca>' >> /etc/openvpn/config/ssl.ovpn;
cat /etc/openvpn/ca.crt >> /etc/openvpn/config/ssl.ovpn;
echo '</ca>' >> /etc/openvpn/config/ssl.ovpn;

# // Make ZIP For OpenVPN
cd /etc/openvpn/config;
zip all.zip tcp.ovpn udp.ovpn ssl.ovpn;
cp all.zip /etc/akubudakgerik/webserver/;
cp tcp.ovpn /etc/akubudakgerik/webserver/;
cp udp.ovpn /etc/akubudakgerik/webserver/;
cp ssl.ovpn /etc/akubudakgerik/webserver/;
cd /root/;

# // Setting IP Tables to MASQUERADE
iptables -t nat -I POSTROUTING -s 10.10.11.0/24 -o $NET -j MASQUERADE;
iptables -t nat -I POSTROUTING -s 10.10.12.0/24 -o $NET -j MASQUERADE;
iptables-save > /etc/iptables.up.rules;
chmod +x /etc/iptables.up.rules;
iptables-restore -t < /etc/iptables.up.rules;
netfilter-persistent save > /dev/null 2>&1;
netfilter-persistent reload > /dev/null 2>&1;

# // Adding Port To IPTables ( OpenVPN 1194 / TCP )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 1194 -j ACCEPT;
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 1194 -j ACCEPT;
iptables-save > /etc/iptables.up.rules;
iptables-restore -t < /etc/iptables.up.rules;
netfilter-persistent save > /dev/null 2>&1;
netfilter-persistent reload > /dev/null 2>&1;

# // Adding Port To IPTables ( OpenVPN 1195 / UDP )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 1195 -j ACCEPT;
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 1195 -j ACCEPT;
iptables-save > /etc/iptables.up.rules;
iptables-restore -t < /etc/iptables.up.rules;
netfilter-persistent save > /dev/null 2>&1;
netfilter-persistent reload > /dev/null 2>&1;

# // Adding Port To IPTables ( OpenVPN 1196 / TCP SSL )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 1196 -j ACCEPT;
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 1196 -j ACCEPT;
iptables-save > /etc/iptables.up.rules;
iptables-restore -t < /etc/iptables.up.rules;
netfilter-persistent save > /dev/null 2>&1;
netfilter-persistent reload > /dev/null 2>&1;

# // Remove Not Used Files
rm -f /root/ovpn.sh;

# // Successfull
clear;
echo -e "${OKEY} Successfull Installed OpenVPN";