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

# // Clear
clear
echo -e "${RED_BG}                 VPS / Sytem Information                  ${NC}";
echo -e "Sever Uptime        = $( uptime -p  | cut -d " " -f 2-10000 ) ";
echo -e "Current Time        = $( date -d "0 days" +"%d-%m-%Y | %X" )";
echo -e "Operating System    = $( cat /etc/os-release | grep -w PRETTY_NAME | sed 's/PRETTY_NAME//g' | sed 's/=//g' | sed 's/"//g' ) ( $( uname -m) )";
echo -e "Current Domain      = $( cat /etc/akubudakgerik/domain.txt )";
echo -e "Server IP           = ${IP_NYA}";
echo -e "Customer ID         = ${PELANGGAN_KE}";
echo -e "Activation Status   = $(if [[ $STATUS_IP == "active" ]]; then
echo -e "Activated"; else
echo -e "Inactive"; fi
)"
echo -e "License Type        = ${TYPE} Edition";
echo -e "License Issued to   = ${NAME}";
echo -e "License Start       = ${CREATED}";
echo -e "License Limit       = $( if [[ $UNLIMITED == "true" ]]; then
echo -e "Unlimited"; else
echo -e "${COUNT}/${LIMIT} VPS"; fi
)"
echo -e "License Expired     = $( if [[ $LIFETIME == "true" ]]; then
echo -e "Lifetime"; else
echo -e "${EXPIRED} ( $days_left Days Left )"; fi
)"

echo -e "";

echo -e "${RED_BG}                VPN Admin/Account Manager                 ${NC}";
echo -e "${GREEN} 1${YELLOW})${NC}. SSH & OpenVPN Account Manager";
echo -e "${GREEN} 2${YELLOW})${NC}. Vmess Account Manager";
echo -e "${GREEN} 3${YELLOW})${NC}. Vless Account Manager";
echo -e "${GREEN} 4${YELLOW})${NC}. Trojan Account Manager";
echo -e "${GREEN} 5${YELLOW})${NC}. Shadowsocks Account Manager";
echo -e "${GREEN} 6${YELLOW})${NC}. ShadowsocksR Account Manager";
echo -e "${GREEN} 7${YELLOW})${NC}. Wireguard Account Manager";
echo -e "${GREEN} 8${YELLOW})${NC}. Socks 4/5 Account Manager";
echo -e "${GREEN} 9${YELLOW})${NC}. HTTP Proxy Account Manager";
echo -e "";
echo -e "${RED_BG}                     Addons Service                       ${NC}";
echo -e "${GREEN}10${YELLOW})${NC}. Benchmark Speed ( Speedtest By Ookla )";
echo -e "${GREEN}11${YELLOW})${NC}. Checking Ram Usage";
echo -e "${GREEN}12${YELLOW})${NC}. Checking Bandwidth Usage";
echo -e "${GREEN}13${YELLOW})${NC}. Change Timezone";
echo -e "${GREEN}14${YELLOW})${NC}. Change License Key";
echo -e "${GREEN}15${YELLOW})${NC}. Autokill Menu | For Pro Only";
echo -e "${GREEN}16${YELLOW})${NC}. Change Domain / Host";

echo -e "${GREEN}17${YELLOW})${NC}. Renew SSL Certificate";
echo -e "${GREEN}18${YELLOW})${NC}. Add Email For Backup";
echo -e "${GREEN}19${YELLOW})${NC}. Backup VPN Client";
echo -e "${GREEN}20${YELLOW})${NC}. Restore VPN Client";
echo -e "${GREEN}21${YELLOW})${NC}. Auto Backup VPN Client";
echo -e "${GREEN}22${YELLOW})${NC}. DNS Changer";
echo -e "${GREEN}23${YELLOW})${NC}. Change Port For SSH & XRay";
echo -e "${GREEN}24${YELLOW})${NC}. System & Service Information";
echo -e "${GREEN}25${YELLOW})${NC}. Check Script Version";
echo -e "${GREEN}26${YELLOW})${NC}. Reboot Your Server";


echo -e "";

read -p "Input Your Choose ( 1-24 ) : " choosemu

case $choosemu in
    # // VPN Menu
    1) ssh-menu ;;
    2) vmess-menu ;;
    3) vless-menu ;;
    4) trojan-menu ;;
    5) ss-menu ;;
    6) ssr-menu ;;
    7) wg-menu ;;
    8) socks-menu ;;
    9) http-menu ;;

    # // Other
    10) clear && speedtest ;;
    11) clear && ram-usage ;;
    12) clear && vnstat ;;
    13)
        clear;
        echo -e "${RED_BG}                    Timezone Changer                       ${NC}";
        echo -e "${GREEN}1${YELLOW})${NC}. Asia / Jakarta / Indonesia ( GMT+7 )"
        echo -e "${GREEN}2${YELLOW})${NC}. Asia / Kuala Lumpur / Malaysia ( GMT+8 )"
        echo -e "${GREEN}3${YELLOW})${NC}. America / Chicago / US Central ( GMT-6 )"

        read -p "Choose one : " soefiewjfwefw
        if [[ $soefiewjfwefw == "1" ]]; then
                ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime;
                clear;
                echo -e "${OKEY} Successfull Set time to Jakarta ( GMT +7 )";
                exit 1;
        elif [[ $soefiewjfwefw == "2" ]]; then
                ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime;
                clear;
                echo -e "${OKEY} Successfull Set time to Malaysia ( GMT +8 )";
                exit 1;
        elif [[ $soefiewjfwefw == "2" ]]; then
                ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime;
                clear;
                echo -e "${OKEY} Successfull Set time to Malaysia ( GMT +8 )";
                exit 1;
        else
                clear;
                sleep 2;
                echo -e "${ERROR} Please Choose One option"
                menu;
        fi
    ;;
    14) lcn-change ;;
    15) autokill-menu ;;
    16) 
        clear;
        read -p "Input Your New Domain : " new_domains
        if [[ $new_domains == "" ]]; then
            clear;
            sleep 2;
            echo -e "${ERROR} Please Input New Domain for contitune";
            menu;
        fi

        # // Stopping Xray nontls
        systemctl stop xray-mini@nontls > /dev/null 2&>1

        # // Input Domain To VPS
        echo "$new_domains" > /etc/akubudakgerik/domain.txt;
        domain=$( cat /etc/akubudakgerik/domain.txt );

        # // Making Certificate
        clear;
        echo -e "${OKEY} Starting Generating Certificate";
        rm -rf /root/.acme.sh;
        mkdir -p /root/.acme.sh;
        wget -q -O /root/.acme.sh/acme.sh "https://rjalil68/vpn-script/Resource/Core/acme.sh";
        chmod +x /root/.acme.sh/acme.sh;
        sudo /root/.acme.sh/acme.sh --register-account -m vpn-script@akubudakgerik.com;
        sudo /root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256 -ak ec-256;

        # // Successfull Change Path to xray
        key_path_default=$( cat /etc/xray-mini/tls.json | jq '.inbounds[0].streamSettings.xtlsSettings.certificates[]' | jq -r '.certificateFile' );
        cp /etc/xray-mini/tls.json /etc/xray-mini/tls.json_temp;
        cat /etc/xray-mini/tls.json_temp | jq 'del(.inbounds[0].streamSettings.xtlsSettings.certificates[] | select(.certificateFile == "'${key_path_default}'"))' > /etc/xray-mini/tls2.json_temp;
        cat /etc/xray-mini/tls2.json_temp | jq '.inbounds[0].streamSettings.xtlsSettings.certificates += [{"certificateFile": "'/root/.acme.sh/${domain}_ecc/fullchain.cer'","keyFile": "'/root/.acme.sh/${domain}_ecc/${domain}.key'"}]' > /etc/xray-mini/tls.json;
        rm -rf /etc/xray-mini/tls2.json_temp;
        rm -rf /etc/xray-mini/tls.json_temp;

        # // Restart
        systemctl restart xray-mini@tls > /dev/null 2>&1
        systemctl restart xray-mini@nontls > /dev/null 2>&1

        # // Success
        echo -e "${OKEY} Your Domain : $domain";
        sleep 2;
        clear;
        echo -e "${OKEY} Successfull Change Domain to $domain";
        exit 1;
    ;;
    17) 
        domain=$(cat /etc/akubudakgerik/domain.txt);
        if [[ $domain == "" ]]; then
            clear;
            echo -e "${ERROR} VPS Having Something Wrong";
            exit 1
        fi
        echo -e "$OKEY Starting Certificate Renewal";
        sudo /root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256;
    ;;
    18)
        clear;
        read -p "Input Your Email : " email_input
        if [[ $email_input == "" ]]; then
            clear;
            echo -e "${ERROR} Please Input Email to contitune";
            exit 1;
        fi
        echo $email_input > /etc/akubudakgerik/email.txt
        clear;
        echo -e "${OKEY} Successfull Set Email For Backup";
    ;;
    19) backup ;;
    20) restore ;;
    21)
        clear;
        echo -e "${RED_BG}               AutoBackup ( 12:00 & 00:00 )                ${NC}";
        echo -e "${GREEN}1${YELLOW})${NC}. Enable AutoBackup"
        echo -e "${GREEN}2${YELLOW})${NC}. Disable AutoBackup"
        read -p "Choose one " choosenya
        if [[ $choosenya == "1" ]]; then 
            echo "0 */12 * * * root /usr/local/sbin/autobackup" > /etc/cron.d/auto-backup;
            /etc/init.d/cron restart;
            clear;
            echo -e "${OKEY} Successfull Enabled autobackup";
            exit 1;
        elif [[ $choosenya == "2" ]]; then
            rm -rf /etc/cron.d/auto-backup;
            /etc/init.d/cron restart;
            clear;
            echo -e "${OKEY} Successfull Disabled autobackup";
            exit 1;
        else
            clear;
            echo -e "${ERROR} Please Select a valid number"
            sleep 2;
            menu;
        fi
    ;;
    22)
        clear;
        read -p "DNS 1 ( Require )  : " dns1nya
        read -p "DNS 2 ( Optional ) : " dns2nya
        if [[ $dns1nya == "" ]]; then
            clear;
            echo -e "${ERROR} Please Input DNS 1";
            exit 1;
        fi
        if [[ $dns2nya == "" ]]; then
            echo "nameserver $dns1nya" > /etc/resolv.conf
            echo -e "${OKEY} Successful Change DNS To $dns1nya";
            exit 1;
        else
            echo "nameserver $dns1nya" > /etc/resolv.conf
            echo "nameserver $dns2nya" >> /etc/resolv.conf
            echo -e "${OKEY} Successful Change DNS To $dns1nya & $dns2nya";
            exit 1;
        fi
    ;;
    23) change-port ;;
    24) infonya ;;
    25) vpnscript ;;
    25) reboot ;;

    *)
        clear;
        sleep 2
        echo -e "${ERROR} Please Input an valid number";
        menu;
    ;;
esac        
