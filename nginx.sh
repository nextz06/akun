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
    rm -f /root/nginx.sh;
    rm -f /root/setup.sh;
    clear
    echo -e "${ERROR} JQ Packages Not installed";
    exit 1;
fi


# // Installing Nginx For Handle GRPC
cd /root/;
apt install libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev -y;
wget -q -O /root/nginx.tar.gz http://nginx.org/download/nginx-1.19.9.tar.gz;
tar -zxvf nginx.tar.gz; cd nginx-1.19.9/;
./configure --prefix=/etc/wildydev21/webserver/ \
            --sbin-path=/usr/sbin/nginx \
            --conf-path=/etc/nginx/nginx.conf \
            --http-log-path=/var/log/nginx/access.log \
            --error-log-path=/var/log/nginx/error.log \
            --with-pcre  --lock-path=/var/lock/nginx.lock \
            --pid-path=/var/run/nginx.pid \
            --with-http_ssl_module \
            --with-http_image_filter_module=dynamic \
            --modules-path=/etc/nginx/modules \
            --with-http_v2_module \
            --with-stream=dynamic \
            --with-http_addition_module \
            --with-http_mp4_module \
            --with-http_realip_module;
make && make install;
cd && rm -rf /root/nginx-1.19.9 && rm -f /root/nginx.tar.gz;
wget -q -O /lib/systemd/system/nginx.service "https://releases.wildydev21.com/vpn-script/Resource/Service/nginx_service";
systemctl stop nginx;
rm -rf /etc/nginx/sites-*;
mkdir -p /etc/nginx/conf.d/;
wget -q -O /etc/nginx/nginx.conf "https://releases.wildydev21.com/vpn-script/Resource/Config/nginx_conf";
wget -q -O /etc/nginx/conf.d/wildydev21.conf "https://releases.wildydev21.com/vpn-script/Resource/Config/wildydev21_conf";
mkdir -p /etc/wildydev21/webserver/;
wget -q -O /etc/wildydev21/webserver/index.html "https://releases.wildydev21.com/vpn-script/Resource/Config/index.file";
sudo chown -R www-data:www-data /etc/wildydev21/webserver/;
sudo chmod 755 /etc/wildydev21/webserver/;
systemctl enable nginx;
systemctl start nginx;

# // Remove not used file
rm -f /root/nginx.sh;

# // Successfull
clear;
echo -e "${OKEY} Successfull Installed Nginx";