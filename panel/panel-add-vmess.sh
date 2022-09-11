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

# // Clear Data
clear;

# // String
user_tag="$1";
pass_tag="$3";
exp_tag="$5";
username="$2";
password="$4";
expired="$6";

if [[ $user_tag == "--user" ]]; then
    SKIP=TRUE;
else
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi
if [[ $pass_tag == "--uuid" ]];  then
    SKIP=TRUE;
else
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi
if [[ $exp_tag == "--exp" ]]; then
    SKIP=true;
else
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi
if [[ $username == "" ]]; then
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi
if [[ $password == "" ]]; then
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi
if [[ $expired == "" ]]; then
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi

# // Input Data
Username=$username;
uuid=$password;
Jumlah_Hari=$expired;

# // Creating User database file
touch /etc/xray-mini/client.conf;

# // Expired Date
exp=`date -d "$Jumlah_Hari days" +"%Y-%m-%d"`;
hariini=`date -d "0 days" +"%Y-%m-%d"`;

# // Generate New UUID & Domain
domain=$( cat /etc/wildydev21/domain.txt );

# // Force create folder for fixing account wasted
mkdir -p /etc/wildydev21/cache/;
mkdir -p /etc/xray-mini/;
mkdir -p /etc/wildydev21/xray-mini-tls/;
mkdir -p /etc/wildydev21/xray-mini-nontls/;

# // Getting Vmess port using grep from config
tls_port=$( cat /etc/xray-mini/tls.json | grep -w port | awk '{print $2}' | head -n1 | sed 's/,//g' | tr '\n' ' ' | tr -d '\r' | tr -d '\r\n' | sed 's/ //g' );
nontls_port=$( cat /etc/xray-mini/nontls.json | grep -w port | awk '{print $2}' | head -n1 | sed 's/,//g' | tr '\n' ' ' | tr -d '\r' | tr -d '\r\n' | sed 's/ //g' );

export CHK=$( cat /etc/xray-mini/tls.json );
if [[ $CHK == "" ]]; then
    clear;
    echo -e "${ERROR} Your VPS Crash, Contact admin for fix it";
    exit 1;
fi

# // Input Your Data to server
cp /etc/xray-mini/tls.json /etc/wildydev21/xray-mini-utils/tls-backup.json;
cat /etc/wildydev21/xray-mini-utils/tls-backup.json | jq '.inbounds[2].settings.clients += [{"id": "'${uuid}'","email": "'${Username}'","alterid": '"0"'}]' > /etc/wildydev21/xray-mini-cache.json;
cat /etc/wildydev21/xray-mini-cache.json | jq '.inbounds[5].settings.clients += [{"id": "'${uuid}'","email": "'${Username}'","alterid": '"0"'}]' > /etc/xray-mini/tls.json;
cp /etc/xray-mini/nontls.json /etc/wildydev21/xray-mini-utils/nontls-backup.json;
cat /etc/wildydev21/xray-mini-utils/nontls-backup.json | jq '.inbounds[0].settings.clients += [{"id": "'${uuid}'","email": "'${Username}'","alterid": '"0"'}]' > /etc/xray-mini/nontls.json;
echo -e "Vmess $Username $exp" >> /etc/xray-mini/client.conf;

cat > /etc/wildydev21/cache/vmess-tls-gun.tmp << END
{"add":"${domain}","aid":"0","host":"","id":"${uuid}","net":"grpc","path":"Vmess-GRPC","port":"${tls_port}","ps":"${Username}","scy":"none","sni":"","tls":"tls","type":"gun","v":"2"}
END

cat > /etc/wildydev21/cache/vmess-tls-ws.tmp << END
{"add":"${domain}","aid":"0","host":"","id":"${uuid}","net":"ws","path":"/vmess","port":"${tls_port}","ps":"${Username}","scy":"none","sni":"${domain}","tls":"tls","type":"","v":"2"}
END

cat > /etc/wildydev21/cache/vmess-nontls.tmp << END
{"add":"${domain}","aid":"0","host":"","id":"${uuid}","net":"ws","path":"/vmess","port":"${nontls_port}","ps":"${Username}","scy":"none","sni":"","tls":"","type":"","v":"2"}
END

# // Make Config Link
grpc_link="vmess://$(base64 -w 0 /etc/wildydev21/cache/vmess-tls-gun.tmp)";
ws_tls_link="vmess://$(base64 -w 0 /etc/wildydev21/cache/vmess-tls-ws.tmp)";
ws_nontls_link="vmess://$(base64 -w 0 /etc/wildydev21/cache/vmess-nontls.tmp)";

# // Restarting XRay Service
systemctl enable xray-mini@tls;
systemctl enable xray-mini@nontls;
systemctl start xray-mini@tls;
systemctl start xray-mini@nontls;
systemctl restart xray-mini@tls;
systemctl restart xray-mini@nontls;

# // Make Client Folder for save the configuration
mkdir -p /etc/wildydev21/vmess/;
mkdir -p /etc/wildydev21/vmess/${Username};
rm -f /etc/wildydev21/vmess/${Username}/config.log;

# // Success
sleep 1;
clear;
echo -e "Create From Panel | Vmess" | tee -a /etc/wildydev21/shadowsocks/${Username}/config.log;
echo -e "===============================" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e " Remarks     = ${Username}" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e " IP          = ${IP_NYA}" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e " Address     = ${domain}" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e " Port TLS    = ${tls_port}" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e " Port NTLS   = ${nontls_port}" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e " User ID     = ${uuid}" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e "===============================" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e " GRPC VMESS CONFIG LINK" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e ' ```'${grpc_link}'```' | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e "===============================" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e " WS TLS VMESS CONFIG LINK" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e ' ```'${ws_tls_link}'```' | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e "===============================" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e " WS NTLS VMESS CONFIG LINK" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e ' ```'${ws_nontls_link}'```' | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e "===============================" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e " Created     = ${hariini}" | tee -a /etc/wildydev21/vmess/${Username}/config.log;
echo -e " Expired     = ${exp}";
echo -e "===============================";