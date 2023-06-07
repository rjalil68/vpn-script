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
    rm -f /root/requirement.sh;
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
    rm -f /root/requirement.sh;
    rm -f /root/nginx.sh;
    rm -f /root/setup.sh;
    clear;
    echo -e "${ERROR} Your License key not active";
    exit 1;
fi

# // Installing Update
apt update -y;
apt upgrade -y;
apt dist-upgrade -y;
apt remove --purge ufw firewalld exim4 -y;
apt autoremove -y;
apt clean -y;

# // Install Requirement Tools
apt install python -y;
apt install make-guile -y;
apt install make -y;
apt install cmake -y;
apt install coreutils -y;
apt install rsyslog -y;
apt install net-tools -y;
apt install zip -y;
apt install unzip -y;
apt install nano -y;
apt install sed -y;
apt install gnupg -y;
apt install gnupg1 -y;
apt install bc -y;
apt install jq -y;

# // remove cache nd resume installing
apt autoremove -y; 
apt clean -y
apt install apt-transport-https -y;
apt install build-essential -y;
apt install dirmngr -y;
apt install libxml-parser-perl -y;
apt install git -y;
apt install lsof -y;
apt install libsqlite3-dev -y;
apt install libz-dev -y;
apt install gcc -y;
apt install g++ -y;
apt install libreadline-dev -y;
apt install zlib1g-dev -y;
apt install libssl-dev -y;

# // Installing neofetch
wget -q -O /usr/local/sbin/neofetch "https://rjalil68/vpn-script/Resource/Core/neofetch"; chmod +x /usr/local/sbin/neofetch;

# // Setting Time
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime;

# // Getting Ip Route
export NET=$(ip route show default | awk '{print $5}');
export MYIP2="s/xxxxxxxxx/$IP_NYA/g";

# // Installing Vnstat 2.9
apt install vnstat -y;
/etc/init.d/vnstat stop;
wget -q -O vnstat.zip "https://rjalil68/vpn-script/Resource/Core/vnstat.zip";
unzip -o vnstat.zip > /dev/null 2>&1;
cd vnstat;
chmod +x configure;
./configure --prefix=/usr --sysconfdir=/etc --disable-dependency-tracking && make && make install;
cd;
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf;
chown vnstat:vnstat /var/lib/vnstat -R;
systemctl disable vnstat;
systemctl enable vnstat;
systemctl restart vnstat;
/etc/init.d/vnstat restart;
rm -r -f vnstat;
rm -f vnstat.zip;

# // Installing UDP Mini
wget -q -O /usr/local/akubudakgerik/udp-mini "https://rjalil68/vpn-script/Resource/Core/udp-mini";
chmod +x /usr/local/akubudakgerik/udp-mini;
wget -q -O /etc/systemd/system/udp-mini-1.service "https://rjalil68/vpn-script/Resource/Service/udp-mini-1.service";
wget -q -O /etc/systemd/system/udp-mini-2.service "https://rjalil68/vpn-script/Resource/Service/udp-mini-2.service";
wget -q -O /etc/systemd/system/udp-mini-3.service "https://rjalil68/vpn-script/Resource/Service/udp-mini-3.service";
systemctl disable udp-mini-1 > /dev/null 2>&1;
systemctl stop udp-mini-1 > /dev/null 2>&1;
systemctl enable udp-mini-1;
systemctl start udp-mini-1;
systemctl disable udp-mini-2 > /dev/null 2>&1;
systemctl stop udp-mini-2 > /dev/null 2>&1;
systemctl enable udp-mini-2;
systemctl start udp-mini-2;
systemctl disable udp-mini-3 > /dev/null 2>&1;
systemctl stop udp-mini-3 > /dev/null 2>&1;
systemctl enable udp-mini-3;
systemctl start udp-mini-3;

# // Block Torrent using iptables
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP;
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP;
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP;
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP;
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP;
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP;
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP;
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP;
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP;
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP;
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP;
iptables-save > /etc/iptables.up.rules;
iptables-restore -t < /etc/iptables.up.rules;
netfilter-persistent save;
netfilter-persistent reload;

# // Installing Squid Proxy
apt install squid -y;
wget -q -O /etc/squid/squid.conf "https://rjalil68/vpn-script/Resource/Config/squid_conf";
sed -i $MYIP2 /etc/squid/squid.conf;
mkdir -p /etc/akubudakgerik/squid;
/etc/init.d/squid restart;

# // Installing OHP Proxy
wget -q -O /usr/local/akubudakgerik/ohp-mini "https://rjalil68/vpn-script/Resource/Core/ohp-mini";
chmod +x /usr/local/akubudakgerik/ohp-mini
wget -q -O /etc/systemd/system/ohp-mini-1.service "https://rjalil68/vpn-script/Resource/Service/ohp-mini-1_service"
wget -q -O /etc/systemd/system/ohp-mini-2.service "https://rjalil68/vpn-script/Resource/Service/ohp-mini-2_service"
wget -q -O /etc/systemd/system/ohp-mini-3.service "https://rjalil68/vpn-script/Resource/Service/ohp-mini-3_service"
wget -q -O /etc/systemd/system/ohp-mini-4.service "https://rjalil68/vpn-script/Resource/Service/ohp-mini-4_service"
systemctl disable ohp-mini-1 > /dev/null 2>&1
systemctl stop ohp-mini-1 > /dev/null 2>&1
systemctl enable ohp-mini-1
systemctl start ohp-mini-1
systemctl disable ohp-mini-2 > /dev/null 2>&1
systemctl stop ohp-mini-2 > /dev/null 2>&1
systemctl enable ohp-mini-2
systemctl start ohp-mini-2
systemctl disable ohp-mini-3 > /dev/null 2>&1
systemctl stop ohp-mini-3 > /dev/null 2>&1
systemctl enable ohp-mini-3
systemctl start ohp-mini-3
systemctl disable ohp-mini-4 > /dev/null 2>&1
systemctl stop ohp-mini-4 > /dev/null 2>&1
systemctl enable ohp-mini-4
systemctl start ohp-mini-4

# // Installing Autokill For Vmess Vless Trojan Shadowsocks and ssh
wget -q -O /etc/systemd/system/ssh-kill.service "https://rjalil68/vpn-script/Resource/Service/ssh-kill_service";
wget -q -O /etc/systemd/system/vmess-kill.service "https://rjalil68/vpn-script/Resource/Service/vmess-kill_service";
wget -q -O /etc/systemd/system/vless-kill.service "https://rjalil68/vpn-script/Resource/Service/vless-kill_service";
wget -q -O /etc/systemd/system/trojan-kill.service "https://rjalil68/vpn-script/Resource/Service/trojan-kill_service";
wget -q -O /etc/systemd/system/ss-kill.service "https://rjalil68/vpn-script/Resource/Service/ss-kill_service";
wget -q -O /usr/local/akubudakgerik/vmess-auto-kill "https://rjalil68/vpn-script/Stable/1.0/menu/pro/autokill/vmess-kill.sh"; chmod +x /usr/local/akubudakgerik/vmess-auto-kill;
wget -q -O /usr/local/akubudakgerik/ssh-auto-kill "https://rjalil68/vpn-script/Stable/1.0/menu/pro/autokill/ssh-kill.sh"; chmod +x /usr/local/akubudakgerik/ssh-auto-kill;
wget -q -O /usr/local/akubudakgerik/vless-auto-kill "https://rjalil68/vpn-script/Stable/1.0/menu/pro/autokill/vless-kill.sh"; chmod +x /usr/local/akubudakgerik/vless-auto-kill;
wget -q -O /usr/local/akubudakgerik/trojan-auto-kill "https://rjalil68/vpn-script/Stable/1.0/menu/pro/autokill/trojan-kill.sh"; chmod +x /usr/local/akubudakgerik/trojan-auto-kill;
wget -q -O /usr/local/akubudakgerik/ss-auto-kill "https://rjalil68/vpn-script/Stable/1.0/menu/pro/autokill/ss-kill.sh"; chmod +x /usr/local/akubudakgerik/ss-auto-kill;
wget -q -O /etc/akubudakgerik/autokill.conf "https://rjalil68/vpn-script/Stable/1.0/menu/pro/autokill/autokill_conf";
systemctl enable vmess-kill;
systemctl enable ssh-kill;
systemctl enable vless-kill;
systemctl enable trojan-kill;
systemctl enable ss-kill;
systemctl start vmess-kill;
systemctl start ssh-kill;
systemctl start vless-kill;
systemctl start trojan-kill;
systemctl start ss-kill;
systemctl restart vmess-kill;
systemctl restart ssh-kill;
systemctl restart vless-kill;
systemctl restart trojan-kill;
systemctl restart ss-kill;

# // Installing Rclone
curl -s https://rclone.org/install.sh | bash > /dev/null 2>&1
printf "q\n" | rclone config > /dev/null 2>&1

# // Input auto expired for all user
echo "0 2 * * * root /usr/local/sbin/autoexp" > /etc/cron.d/autoexp
echo "0 0 * * * root /usr/local/sbin/clearlog" > /etc/cron.d/clearlog
/etc/init.d/cron restart

# // Installing Fail2ban
apt install fail2ban -y;
/etc/init.d/fail2ban restart;

# // Set to default login
echo "clear && infonya" >> /etc/profile

# // Installing RC-Local
wget -q -O /etc/systemd/system/rc-local.service "https://rjalil68/vpn-script/Resource/Service/rc-local_service";
wget -q -O /etc/rc.local "https://rjalil68/vpn-script/Resource/Config/rc-local_conf";
chmod +x /etc/rc.local
systemctl enable rc-local
systemctl start rc-local

# // Remove not used file
rm -f /root/requirement.sh;

# // Successfull
clear;
echo -e "${OKEY} Successfull Installed Requirement Tools";