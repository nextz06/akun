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
    rm -f /root/xray-mini.sh;
    rm -f /root/nginx.sh;
    rm -f /root/setup.sh;
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

# // Stopping Service if running
systemctl stop xray-mini@tls > /dev/null 2>&1
systemctl stop xray-mini@nontls > /dev/null 2>&1

# // Make Folder For Service
mkdir -p /usr/local/wildydev21/;

# // Downloading XRay Mini Core
wget -q -O /usr/local/wildydev21/xray-mini "https://releases.wildydev21.com/vpn-script/Resource/Core/xray-mini";
chmod +x /usr/local/wildydev21/xray-mini;

# // Downloading XRay Mini Service
wget -q -O /etc/systemd/system/xray-mini@.service "https://releases.wildydev21.com/vpn-script/Resource/Service/xray-mini_service";
chmod +x /etc/systemd/system/xray-mini@.service;

# // Removing Old Folder
rm -rf /etc/xray-mini/;
rm -rf /etc/wildydev21/xray-mini-tls/;
rm -rf /etc/wildydev21/xray-mini-nontls/;
rm -rf /etc/wildydev21/xray-mini-shadowsocks/;
rm -rf /etc/wildydev21/xray-mini-socks/;

# // Make Xray-Mini Folder
mkdir -p /etc/xray-mini/;
mkdir -p /etc/wildydev21/xray-mini-nontls/;
mkdir -p /etc/wildydev21/xray-mini-tls/;
mkdir -p /etc/wildydev21/vmess/;
mkdir -p /etc/wildydev21/vless/;
mkdir -p /etc/wildydev21/trojan/;
mkdir -p /etc/wildydev21/cache/;
mkdir -p /etc/wildydev21/xray-mini-utils/;
mkdir -p /etc/wildydev21/xray-mini-shadowsocks/;
mkdir -p /etc/wildydev21/xray-mini-socks/;
touch /etc/xray-mini/client.conf;

# // Getting Domain Addres
export domain=$( cat /etc/wildydev21/domain.txt );

# // Downloading XRay TLS Config
wget -qO- "https://releases.wildydev21.com/vpn-script/Resource/Xray-Mini/1.0.Stable/tls_json" | jq '.inbounds[0].streamSettings.xtlsSettings.certificates += [{"certificateFile": "'/root/.acme.sh/${domain}_ecc/fullchain.cer'","keyFile": "'/root/.acme.sh/${domain}_ecc/${domain}.key'"}]' > /etc/xray-mini/tls.json;
wget -q -O /etc/xray-mini/nontls.json "https://releases.wildydev21.com/vpn-script/Resource/Xray-Mini/1.0.Stable/nontls_json";
wget -q -O /etc/xray-mini/shadowsocks.json "https://releases.wildydev21.com/vpn-script/Resource/Xray-Mini/1.0.Stable/shadowsocks_json";
wget -q -O /etc/xray-mini/socks.json "https://releases.wildydev21.com/vpn-script/Resource/Xray-Mini/1.0.Stable/socks_json";
wget -q -O /etc/xray-mini/http.json "https://releases.wildydev21.com/vpn-script/Resource/Xray-Mini/1.0.Stable/http_json";

# // Removing Apache 2 if existed
systemctl stop apache2 > /dev/null 2>&1;
apt remove --purge apache2 -y;
apt autoremove -y;

# // Enable XRay Service
systemctl enable xray-mini@shadowsocks;
systemctl enable xray-mini@tls;
systemctl enable xray-mini@nontls;
systemctl enable xray-mini@socks;
systemctl enable xray-mini@http;
systemctl start xray-mini@shadowsocks;
systemctl start xray-mini@tls;
systemctl start xray-mini@nontls;
systemctl start xray-mini@socks;
systemctl start xray-mini@http;
systemctl restart xray-mini@shadowsocks;
systemctl restart xray-mini@nontls
systemctl restart xray-mini@tls
systemctl restart xray-mini@socks
systemctl restart xray-mini@http

# // Remove not used file
rm -f /root/xray-mini.sh;

# // Successfull
clear;
echo -e "${OKEY} Successfull Installed XRay-Mini 1.5.5";