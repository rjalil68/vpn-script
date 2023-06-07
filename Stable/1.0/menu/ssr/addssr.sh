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

# // Start Menu
echo " List Of Avaiable ShadowsocksR Protocols";
echo "===============================================";
echo "  1. origin";
echo "  2. auth_sha1";
echo "  3. auth_sha1_v2";
echo "  4. auth_sha1_v4";
echo "===============================================";
read -p "Choose One Protocols You Want Use ( 1-4 ) : " choose_protocols;
case $choose_protocols in
    1) # Origin
        Protocols="origin";
    ;;
    2) # auth_sha1
        Protocols="auth_sha1";
    ;;
    3) # auth_sha1_v2
        Protocols="auth_sha1_v2";
    ;;
    4) # auth_sha1_v4
        Protocols="auth_sha1_v4";
    ;;
    *) # No Choose
        clear;
        echo -e "${ERROR} Please Choose One Protocols !";
        exit 1;
    ;;
esac

# // Clear
clear;

# // Choose Obfs
echo " List Of Avaiable ShadowsocksR Obfs";
echo "===============================================";
echo " 1. plain";
echo " 2. http_simple";
echo " 3. http_post";
echo " 4. tls_simple";
echo " 5. tls1.2_ticket_auth";
echo "===============================================";
read -p "Choose One Obfs You Want Use ( 1-5 ) : " choose_obfs;
case $choose_obfs in
    1) # plain
        obfs="plain";
    ;;
    2) # http_simple
        obfs="http_simple";
    ;;
    3) # http_post
        obfs="http_post";
    ;;
    4) # tls_simple
        obfs="tls_simple";
    ;;
    5) # tls1.2_ticket_auth_compatible
        obfs="tls1.2_ticket_auth_compatible";
    ;;
    *) # No Choose
        clear;
        echo -e "${ERROR} Please Choose One Obfs !";
        exit 1;
    ;;
esac

clear;

read -p "Username   : " Username;
Username="$(echo ${Username} | sed 's/ //g' | tr -d '\r')";

touch /etc/akubudakgerik/ssr-client.conf
if [[ $Username == "$( cat /etc/akubudakgerik/ssr-client.conf | grep -w $Username | head -n1 | awk '{print $2}' )" ]]; then
clear;
echo -e "${ERROR} Account With ( ${YELLOW}$Username ${NC}) Already Exists !";
exit 1;
fi
Domain=$( cat /etc/akubudakgerik/domain.txt );

read -p "Max Login  : " max_log;
if [[ $max_log == "" ]]; then
    clear;
    echo -e "${ERROR} Please Input Max Login";
    exit 1;
fi
read -p "Expired    : " Jumlah_Hari;
clear;
echo "===================================================";
echo " Press [ ENTER ] to disable bandwidth limiting";
echo " The bandwidth limit is calculated in Giga Bytes";
echo " Example | Limit 1TB Bandwidth Just Type 1024";
echo "===================================================";
echo "";
read -p "Bandwidth Limit : " bandwidth_allowed;

if [[ $bandwidth_allowed == "" ]]; then
    bandwidth_alloweds="Unlimited";
    bandwidth_allowed="1024000";
else
    bandwidth_alloweds="$bandwidth_allowed GB";
fi

# // Count Date
exp=`date -d "$Jumlah_Hari days" +"%Y-%m-%d"`;
hariini=`date -d "0 days" +"%Y-%m-%d"`;

# // Port Configuration
if [[ $(cat /etc/akubudakgerik/ssr-server/mudb.json | grep '"port": ' | tail -n1 | awk '{print $2}' | cut -d "," -f 1 | cut -d ":" -f 1 ) == "" ]]; then
Port=1200;
else
Port=$(( $(cat /etc/akubudakgerik/ssr-server/mudb.json | grep '"port": ' | tail -n1 | awk '{print $2}' | cut -d "," -f 1 | cut -d ":" -f 1 ) + 1 ));
fi

# // Adding User To Configuration
echo -e "SSR $Username $exp $Port" >> /etc/akubudakgerik/ssr-client.conf;

# // Adding User To ShadowsocksR Server
cd /etc/akubudakgerik/ssr-server/;
match_add=$(python mujson_mgr.py -a -u "${Username}" -p "${Port}" -k "${Username}" -m "aes-256-cfb" -O "${Protocols}" -G "${max_log}" -o "${obfs}" -s "0" -S "0" -t "${bandwidth_allowed}" -f "bittorrent" | grep -w "add user info");
cd;

# // Make Client Configuration Link
tmp1=$(echo -n "${Username}" | base64 -w0 | sed 's/=//g;s/\//_/g;s/+/-/g');
SSRobfs=$(echo ${obfs} | sed 's/_compatible//g');
tmp2=$(echo -n "${IP}:${Port}:${Protocols}:aes-256-cfb:${SSRobfs}:${tmp1}/obfsparam=" | base64 -w0);
ssr_link="ssr://${tmp2}";

# // Restarting Service
/etc/init.d/ssr-server restart;

# // Make Cache Folder
rm -rf /etc/akubudakgerik/ssr/${Username};
mkdir -p /etc/akubudakgerik/ssr/${Username}/

# // Clear
clear;

# // Successfull
echo "Your Premium ShadowsocksR" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo "==============================" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo " IP         = "'```'"${IP}"'```'"" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo " Domain     = $Domain" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo " Username   = $Username" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo " Password   = $Username" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo " Port       = $Port" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo " Protocols  = $Protocols" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo " Obfs       = $obfs" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo " Max Login  = $max_log Device" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo " BW Limit   = $bandwidth_alloweds" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo "==============================" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo " ShadowsocksR Config Link" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo ' ```'$ssr_link'```' | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo "==============================" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo " Created    = $hariini" | tee -a /etc/akubudakgerik/ssr/${Username}/config.log;
echo " Expired    = $exp";
echo "==============================";