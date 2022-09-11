#!/bin/bash
# (C) Copyright 2021-2022 By WildyDev21
# ==================================================================
# Name        : VPN Script Quick Installation Script
# Description : This Script Is Setup for running other
#               quick Setup script from one click installation
# Created     : 16-05-2022 ( 16 May 2022 )
# OS Support  : Ubuntu & Debian
# Auther      : WildyDev21
# WebSite     : https://wildydev21.com
# Github      : github.com/wildydev21
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
export AUTHER="WildyDev21";
export ROOT_DIRECTORY="/etc/wildydev21";
export CORE_DIRECTORY="/usr/local/wildydev21";
export SERVICE_DIRECTORY="/etc/systemd/system";
export SCRIPT_SETUP_URL="https://releases.wildydev21.com/vpn-script";
export REPO_URL="https://repository.wildydev21.com";

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
wget -qO- --inet4-only 'https://releases.wildydev21.com/vpn-script/get-ip_sh' | bash;
source /root/ip-detail.txt;
export IP_NYA="$IP";
export ASN_NYA="$ASN";
export ISP_NYA="$ISP";
export REGION_NYA="$REGION";
export CITY_NYA="$CITY";
export COUNTRY_NYA="$COUNTRY";
export TIME_NYA="$TIMEZONE";

# // Clear
clear;
ssh_ssl=$( cat /lib/systemd/system/sslh.service | grep -w ExecStart | head -n1 | awk '{print $6}' | sed 's/0.0.0.0//g' | sed 's/://g' | tr '\n' ' ' | tr -d '\r' | sed 's/ //g' );
ssl_xray=$( cat /etc/xray-mini/tls.json | grep -w port | awk '{print $2}' | head -n1 | sed 's/,//g' | tr '\n' ' ' | tr -d '\r' | tr -d '\r\n' | sed 's/ //g' );

# // Change Port
echo -e "${RED_BG}                       Port Changer                        ${NC}";
echo -e "${GREEN}1${YELLOW})${NC}. Change SSH Port            | ${ssh_ssl} ";
echo -e "${GREEN}2${YELLOW})${NC}. Change Vmess Vless Trojan  | ${ssl_xray}";
echo "";
read -p "Choose One (1-2) : " choosemu_lah
if [[ $choosemu_lah == "1" ]]; then
        clear;
        read -p "Input New Port : " new_port;
        if [[ $new_port == "" ]]; then
            clear;
            echo -e "${ERROR} Please input new port";
            exit 1;
        else
            sed -i "s/127.0.0.1:${ssh_ssl}/127.0.0.1:${new_port}/g" /etc/stunnel5/stunnel5.conf;
            sed -i "s/0.0.0.0:${ssh_ssl}/0.0.0.0:${new_port}/g" /lib/systemd/system/sslh.service;
            systemctl daemon-reload;
            systemctl restart sslh;
            systemctl restart stunnel5;
        fi
        clear;
        echo -e "${OKEY} Successfull Changed SSH Port to ${new_port}";
        exit 1;
elif [[ $choosemu_lah == "2" ]]; then
        clear;
        read -p "Input New Port : " new_port
        if [[ $new_port == "" ]]; then
            clear;
            echo -e "${ERROR} Please input new port";
            exit 1;
        else
            sed -i "s/${ssl_xray}/${new_port}/g" /etc/xray-mini/tls.json;
            systemctl daemon-reload;
            systemctl restart xray-mini@tls;
        fi
        clear;
        echo -e "${OKEY} Successfull Changed XRay TLS Port to ${new_port}"
else
    clear;
    echo -e "${ERROR} Please Input a valid number";
    exit 1;
fi