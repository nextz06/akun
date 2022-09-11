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
		echo -e " ${ERROR} Please run this script as root user";
		exit 1;
fi

# // Checking Requirement Installed / No
if ! which jq > /dev/null; then
    rm -f /root/ssr.sh;
    rm -f /root/ovpn.sh;
    rm -f /root/ssh-ssl.sh;
    rm -f /root/requirement.sh;
    rm -f /root/nginx.sh;
    rm -f /root/setup.sh;
    clear
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

# // Take VPS IP & Network Interface
MYIP2="s/xxxxxxxxx/$IP_NYA/g";
NET=$(ip route show default | awk '{print $5}');

# // Make SSR Server Main Directory
rm -r -f /etc/wildydev21/ssr-server;
mkdir -p /etc/wildydev21/ssr-server;

# // Installing Requirement Package
apt update -y;
apt install unzip -y;
apt install cron -y;
apt install git -y;
apt install net-tools -y;

# // Install Python2
apt install python -y;

# // ShadowsocksR Setup
cd /etc/wildydev21/ssr-server/;
wget -q -O /etc/wildydev21/ssr-server/SSR-Server.zip "https://releases.wildydev21.com/vpn-script/Resource/Core/SSR-Server.zip";
unzip -o SSR-Server.zip > /dev/null 2>&1;
chmod +x jq;
rm -f SSR-Server.zip;
cp config.json /etc/wildydev21/ssr-server/user-config.json;
cp mysql.json /etc/wildydev21/ssr-server/usermysql.json;
cp apiconfig.py /etc/wildydev21/ssr-server/userapiconfig.py;
sed -i "s/API_INTERFACE = 'sspanelv2'/API_INTERFACE = 'mudbjson'/" /etc/wildydev21/ssr-server/userapiconfig.py;
sed -i "s/SERVER_PUB_ADDR = '127.0.0.1'/SERVER_PUB_ADDR = '${IP_NYA}'/" /etc/wildydev21/ssr-server/userapiconfig.py;
sed -i 's/ \/\/ only works under multi-user mode//g' /etc/wildydev21/ssr-server/user-config.json;
cd;

# // Enable IPTables
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 1200:1300 -j ACCEPT;
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 1200:1300 -j ACCEPT;

# // Saving IPTables Configuration
iptables-save > /etc/iptables.up.rules;

# // Downloading SSR Server Init.d
wget -q -O /etc/init.d/ssr-server "https://releases.wildydev21.com/vpn-script/Resource/Service/ssr-server_init";
chmod +x /etc/init.d/ssr-server;
/etc/init.d/ssr-server start;

# // Starting Service
systemctl daemon-reload;
systemctl start ssr-server;

# // Remove Not Used Files
rm -rf /root/ssr.sh;

# // Successfull
clear;
echo -e "${OKEY} Successfull Installed SSR";