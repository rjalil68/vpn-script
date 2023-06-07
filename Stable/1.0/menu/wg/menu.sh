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

# // Start
clear;
echo -e "${RED_BG}                      Wireguard Tunnel                    ${NC}";
echo -e "${GREEN} 1${YELLOW})${NC}. Create Wireguard Account";
echo -e "${GREEN} 2${YELLOW})${NC}. Delete Wireguard Account";
echo -e "${GREEN} 3${YELLOW})${NC}. Renew Wireguard Account";
echo -e "${GREEN} 4${YELLOW})${NC}. List Config of Wireguard Account";
echo -e "${GREEN} 5${YELLOW})${NC}. Generate Wireguard trial Account";
echo -e "${GREEN} 6${YELLOW})${NC}. Remove All Expired Account";
echo -e "${GREEN} 7${YELLOW})${NC}. Check Wireguard User Login Session";
echo -e "${GREEN} 8${YELLOW})${NC}. All Wireguard Account List";
echo "";
read -p "Please Choose one : " selection_mu;

node_name=wg;

case $selection_mu in
    1)
        add${node_name};
    ;;
    2)
        del${node_name};
    ;;
    3)
        renew${node_name};
    ;;
    4)
        ${node_name}config;
    ;;
    5)
        trial${node_name};
    ;;
    6)
        ${node_name}exp;
    ;;
    7)
        chk${node_name};
    ;;
    8)
        ${node_name}list;
    ;;
    *)
        echo -e "${ERROR} Your Input is Wrong";
        sleep 1;
        ${node_name}-menu;
    ;;
esac