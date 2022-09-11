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

# // Start
grep -c -E "^Socks " "/etc/xray-mini/client.conf" > /etc/wildydev21/jumlah-akun-socks.db;
grep "^Socks " "/etc/xray-mini/client.conf" | awk '{print $2}'  > /etc/wildydev21/akun-socks.db;
totalaccounts=`cat /etc/wildydev21/akun-socks.db | wc -l`;
echo "Total Akun = $totalaccounts" > /etc/wildydev21/total-akun-socks.db;
for((i=1; i<=$totalaccounts; i++ ));
do
    # // Username Interval Counting
    username=$( head -n $i /etc/wildydev21/akun-socks.db | tail -n 1 );
    expired=$( grep "^Socks " "/etc/xray-mini/client.conf" | grep -w $username | head -n1 | awk '{print $3}' );

    # // Counting On Simple Algoritmatika
    now=`date -d "0 days" +"%Y-%m-%d"`;
    d1=$(date -d "$expired" +%s);
    d2=$(date -d "$now" +%s);
    sisa_hari=$(( (d1 - d2) / 86400 ));

# // Validate Use If Syntax
if [[ $sisa_hari -lt 1 ]]; then
    # // Removing Data From Server Configuration
    cp /etc/xray-mini/socks.json /etc/wildydev21/xray-mini-utils/socks-backup.json;
    cat /etc/wildydev21/xray-mini-utils/socks-backup.json | jq 'del(.inbounds[0].settings.accounts[] | select(.user == "'${username}'"))' > /etc/xray-mini/socks.json;
    rm -rf /etc/wildydev21/socks/${username};
    sed -i "/\b$username\b/d" /etc/xray-mini/client.conf;
    systemctl restart xray-mini@socks;

    # // Successfull Deleted Expired Client
    echo "Username : $username | Expired : $expired | Deleted $now" >> /etc/wildydev21/socks-expired-deleted.db;
    echo "Username : $username | Expired : $expired | Deleted $now";
else
    Skip="true";
fi

# // End Function
done