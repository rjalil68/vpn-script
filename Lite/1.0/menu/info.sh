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
    clear
    echo -e "${ERROR} JQ Packages Not installed";
    exit 1;
fi

# // Check Connection
wget -q --spider https://google.com
if [ $? -eq 0 ]; then
    SKIP=TRUE;
else
    clear;
    echo -e "${ERROR} Your Internet Is No Online."
    exit 1
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
    SKIP=true
else
    clear;
    echo -e "${ERROR} Your IP Got Blacklisted";
    exit 1;
fi

# // Checking License Key
if [[ -r /etc/akubudakgerik/license-key.wd21 ]]; then
    SKIP=true
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

waktu_sekarang=$(date -d "0 days" +"%Y-%m-%d");
expired_date="$EXPIRED";
now_in_s=$(date -d "$waktu_sekarang" +%s);
exp_in_s=$(date -d "$expired_date" +%s);
days_left=$(( ($exp_in_s - $now_in_s) / 86400 ));

# // Code for service
if [[ $(systemctl status nginx | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    NGINX_STT="${GREEN}Running${NC}";
else
    NGINX_STT="${RED}Not Running${NC}";
fi
if [[ $(systemctl status stunnel5 | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    STUNNEL5_STT="${GREEN}Running${NC}";
else
    STUNNEL5_STT="${RED}Not Running${NC}";
fi
if [[ $(systemctl status ssh | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    SSH_STT="${GREEN}Running${NC}";
else
    SSH_STT="${RED}Not Running${NC}";
fi
if [[ $(systemctl status dropbear | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    DROPBEAR_STT="${GREEN}Running${NC}";
else
    DROPBEAR_STT="${RED}Not Running${NC}";
fi
if [[ $(systemctl status ws-epro | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    WSEPRO_STT="${GREEN}Running${NC}";
else
    WSEPRO_STT="${RED}Not Running${NC}";
fi
if [[ $(systemctl status ohp-mini-1 | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    OHP_1="${GREEN}Running${NC}";
else
    OHP_1="${RED}Not Running${NC}";
fi
if [[ $(systemctl status ohp-mini-2 | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    OHP_2="${GREEN}Running${NC}";
else
    OHP_2="${RED}Not Running${NC}";
fi
if [[ $(systemctl status ohp-mini-3 | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    OHP_3="${GREEN}Running${NC}";
else
    OHP_3="${RED}Not Running${NC}";
fi
if [[ $(systemctl status ohp-mini-4 | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    OHP_4="${GREEN}Running${NC}";
else
    OHP_4="${RED}Not Running${NC}";
fi
if [[ $(systemctl status ohp-mini-4 | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    OHP_4="${GREEN}Running${NC}";
else
    OHP_4="${RED}Not Running${NC}";
fi
if [[ $(systemctl status squid | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    SQUID_STT="${GREEN}Running${NC}";
else
    SQUID_STT="${RED}Not Running${NC}";
fi
if [[ $(systemctl status sslh | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    SSLH_STT="${GREEN}Running${NC}";
else
    SSLH_STT="${RED}Not Running${NC}";
fi
if [[ $(systemctl status sslh | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    SSLH_STT="${GREEN}Running${NC}";
else
    SSLH_STT="${RED}Not Running${NC}";
fi
if [[ $(systemctl status xray-mini@tls | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    XRAY_TCP="${GREEN}Running${NC}";
else
    XRAY_TCP="${RED}Not Running${NC}";
fi
if [[ $(systemctl status xray-mini@nontls | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    XRAY_NTLS="${GREEN}Running${NC}";
else
    XRAY_NTLS="${RED}Not Running${NC}";
fi
if [[ $(systemctl status xray-mini@shadowsocks | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    SS_UDP="${GREEN}Running${NC}";
else
    SS_UDP="${RED}Not Running${NC}";
fi
if [[ $(systemctl status xray-mini@socks | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    SOCKS_STT="${GREEN}Running${NC}";
else
    SOCKS_STT="${RED}Not Running${NC}";
fi
if [[ $(systemctl status xray-mini@http | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    HTTP_STT="${GREEN}Running${NC}";
else
    HTTP_STT="${RED}Not Running${NC}";
fi
if [[ $(systemctl status xray-mini@http | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    HTTP_STT="${GREEN}Running${NC}";
else
    HTTP_STT="${RED}Not Running${NC}";
fi
if [[ $(systemctl status ssr-server | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    SSR_UDP="${GREEN}Running${NC}";
else
    SSR_UDP="${RED}Not Running${NC}";
fi
if [[ $(systemctl status wg-quick@wg0 | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    WG_STT="${GREEN}Running${NC}";
else
    WG_STT="${RED}Not Running${NC}";
fi
if [[ $(systemctl status openvpn@tcp | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    OVPN_TCP="${GREEN}Running${NC}";
else
    OVPN_TCP="${RED}Not Running${NC}";
fi
if [[ $(systemctl status openvpn@udp | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    OVPN_UDP="${GREEN}Running${NC}";
else
    OVPN_UDP="${RED}Not Running${NC}";
fi
if [[ $(systemctl status vmess-kill | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    VMESS_KILL="${GREEN}Running${NC}";
else
    VMESS_KILL="${RED}Not Running${NC}";
fi
if [[ $(systemctl status vless-kill | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    VLESS_KILL="${GREEN}Running${NC}";
else
    VLESS_KILL="${RED}Not Running${NC}";
fi
if [[ $(systemctl status trojan-kill | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    TROJAN_KILL="${GREEN}Running${NC}";
else
    TROJAN_KILL="${RED}Not Running${NC}";
fi
if [[ $(systemctl status ss-kill | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    SS_KILL="${GREEN}Running${NC}";
else
    SS_KILL="${RED}Not Running${NC}";
fi
if [[ $(systemctl status ssh-kill | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    SSH_KILL="${GREEN}Running${NC}";
else
    SSH_KILL="${RED}Not Running${NC}";
fi
if [[ $(systemctl status sslh | grep Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == "active" ]]; then
    SSLH_SST="${GREEN}Running${NC}";
else
    SSLH_SST="${RED}Not Running${NC}";
fi

# // Ram Information
while IFS=":" read -r a b; do
    case $a in
        "MemTotal") ((mem_used+=${b/kB})); mem_total="${b/kB}" ;;
        "Shmem") ((mem_used+=${b/kB}))  ;;
        "MemFree" | "Buffers" | "Cached" | "SReclaimable")
        mem_used="$((mem_used-=${b/kB}))"
    ;;
esac
done < /proc/meminfo
Ram_Usage="$((mem_used / 1024))";
Ram_Total="$((mem_total / 1024))";

if [[ -f /etc/cron.d/auto-backup ]]; then
    STT_EMM="${GREEN}Running${NC}"
else 
    STT_EMM="${RED}Not Running${NC}"
fi

# // Clear
clear
echo -e "${RED_BG}                      Announcement                        ${NC}";
curl -s https://rjalil68/vpn-script/announcement.txt
echo "";
echo -e "${RED_BG}                 VPS / Sytem Information                  ${NC}";
echo -e "Sever Uptime        = $( uptime -p  | cut -d " " -f 2-10000 ) ";
echo -e "Current Time        = $( date -d "0 days" +"%d-%m-%Y | %X" )";
echo -e "Operating System    = $( cat /etc/os-release | grep -w PRETTY_NAME | sed 's/PRETTY_NAME//g' | sed 's/=//g' | sed 's/"//g' ) ( $( uname -m) )";
echo -e "Current Domain      = $( cat /etc/akubudakgerik/domain.txt )";
echo -e "Server IP           = ${IP_NYA}";
echo -e "Ram Usage           = ${Ram_Usage} MB";
echo -e "Total Ram           = ${Ram_Total} MB";
echo -e "Available Ram       = $(( $Ram_Total - $Ram_Usage )) MB"
echo -e "Storage Usage       = $(df -h / | awk '{print $3}' | tail -n1 | sed 's/G//g' | sed 's/ //g') GB"
echo -e "Total Storage       = $(df -h / | awk '{print $2}' | tail -n1 | sed 's/G//g' | sed 's/ //g') GB"
echo -e "Available Storage   = $(df -h / | awk '{print $4}' | tail -n1 | sed 's/G//g' | sed 's/ //g') GB"
NET=$(ip route show default | awk '{print $5}' | head -n1);
if [[ $( vnstat -i $NET | grep yesterday | awk '{print $8}' ) == "" ]]; then
    STTD_YESTERDAY='No Have Data For Yesterday';
else
    STTD_YESTERDAY=$( vnstat -i $NET | grep yesterday | awk '{print $8}' );
fi
tanggal=$( date -d "0 days" +"%Y-%m" )
if [[ $( vnstat -i $NET | grep $tanggal | tail -n1 | awk '{print $8}' ) == "" ]]; then
    STTD_BLN='No Have Data For Monthly';
else
    STTD_BLN=$( vnstat -i $NET | grep $tanggal | tail -n1 | awk '{print $8}' );
fi
echo -e "";
echo -e "${RED_BG}                   Network Information                    ${NC}";
echo -e "Monthly Usage       = $STTD_BLN $(vnstat -i $NET | grep $tanggal | tail -n1 | awk '{print $9}' | sed 's/i//g' )"
echo -e "Yesterday Usage     = $STTD_YESTERDAY $( vnstat -i $NET | grep yesterday | awk '{print $9}' | sed 's/i//g' )"
echo -e "Today Usage         = $( vnstat -i $NET | grep today | awk '{print $8}' ) $( vnstat -i $NET | grep today | awk '{print $9}' | sed 's/i//g' )"
echo -e "Average Net Speed   = $(vnstat -i $NET | grep today | awk '{print $11}') $(vnstat -i $NET | grep today | awk '{print $12}')"

echo -e "";
echo -e "${RED_BG}                   License Information                    ${NC}";
echo -e "Customer ID         = ${PELANGGAN_KE}";
echo -e "Activation Status   = $(if [[ $STATUS_IP == "active" ]]; then
echo -e "Activated"; else
echo -e "Inactive"; fi
)"
echo -e "License Type        = ${TYPE} Edition";
echo -e "License Issued to   = ${NAME}";
echo -e "License Limit       = $( if [[ $UNLIMITED == "true" ]]; then
echo -e "Unlimited"; else
echo -e "${COUNT}/${LIMIT} VPS"; fi
)"
echo -e "License Start       = ${CREATED}";
echo -e "License Expired     = $( if [[ $LIFETIME == "true" ]]; then
echo -e "Lifetime"; else
echo -e "${EXPIRED} ( $days_left Days Left )"; fi
)"
echo -e "";

# // Service status
echo -e "${RED_BG}                   Service Information                    ${NC}";
echo -e "SSH                 = ${SSH_STT}";
echo -e "Dropbear            = ${DROPBEAR_STT}";
echo -e "Stunnel5            = ${STUNNEL5_STT}";
echo -e "WS-ePro             = ${WSEPRO_STT}";
echo -e "OHP OpenSSH         = ${OHP_1}"
echo -e "OHP Dropbear        = ${OHP_2}"
echo -e "OHP OpenVPN         = ${OHP_3}"
echo -e "OHP Universal       = ${OHP_4}"
echo -e "Squid Proxy         = ${SQUID_STT}"
echo -e "SSLH                = ${SSLH_SST}"
echo -e "Nginx               = ${NGINX_STT}";
echo -e "Vmess GRPC WS-TLS   = ${XRAY_TCP}"
echo -e "Vless GRPC WS-TLS   = ${XRAY_TCP}"
echo -e "Trojan GRPC WS TCP  = ${XRAY_TCP}"
echo -e "Vmess Ws NonTLS     = ${XRAY_NTLS}"
echo -e "Vless Ws NonTLS     = ${XRAY_NTLS}"
echo -e "Shadowsocks UDP     = ${SS_UDP}"
echo -e "ShadowsocksR        = ${SSR_UDP}"
echo -e "HTTP Proxy          = ${HTTP_STT}"
echo -e "Socks 4/5 Proxy     = ${SOCKS_STT}"
echo -e "WireGuard           = ${WG_STT}"
echo -e "OpenVPN TCP         = ${OVPN_TCP}"
echo -e "OpenVPN UDP         = ${OVPN_UDP}"
echo -e "Vmess AutoKill      = ${VMESS_KILL}"
echo -e "Vless AutoKill      = ${VLESS_KILL}"
echo -e "Trojan AutoKill     = ${TROJAN_KILL}"
echo -e "SS AutoKill         = ${SS_KILL}"
echo -e "SSH AutoKill        = ${SSH_KILL}"
echo -e "AutoBackup          = ${STT_EMM}"
echo ""