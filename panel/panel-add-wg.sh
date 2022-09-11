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
exp_tag="$3";
username="$2";
expired="$4";

if [[ $user_tag == "--user" ]]; then
    SKIP=TRUE;
else
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi
if [[ $exp_tag == "--exp" ]];  then
    SKIP=TRUE;
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
if [[ $expired == "" ]]; then
    clear;
    echo -e "${ERROR} Your Command is wrong";
    exit 1;
fi

# // Input Data
Username=$username;
Jumlah_Hari=$expired;

# // Creating User database file
touch /etc/xray-mini/client.conf;

# // Expired Date
exp=`date -d "$Jumlah_Hari days" +"%Y-%m-%d"`;
hariini=`date -d "0 days" +"%Y-%m-%d"`;

# // Load Wiregaurd String
source /etc/wireguard/string-data;

# // Checknig IP Address
LASTIP=$( cat /etc/wireguard/wg0.conf | grep /32 | tail -n1 | awk '{print $3}' | cut -d "/" -f 1 | cut -d "." -f 4 );
if [[ "$LASTIP" = "" ]]; then
	User_IP="10.10.17.2";
else
	User_IP="10.10.17.$((LASTIP+1))";
fi

# // Client DNS
DNS1=8.8.8.8;
DNS2=8.8.4.4;

# // Domain Export
Domain=$( cat /etc/wildydev21/domain.txt );

# // Generate Client Key
User_Priv_Key=$(wg genkey);
User_PUB_Key=$(echo "$User_Priv_Key" | wg pubkey);
User_Preshared_Key=$(wg genpsk);

# // Make Client Config
cat > /etc/wildydev21/wireguard-cache.tmp << END
[Interface]
PrivateKey = ${User_Priv_Key}
Address = ${User_IP}/24
DNS = ${DNS1},${DNS2}

[Peer]
PublicKey = ${PUB}
PresharedKey = ${User_Preshared_Key}
Endpoint = ${Domain}:${PORT}
AllowedIPs = 0.0.0.0/0,::/0
END

# // Input Data User Ke Wireguard Server
cat >> /etc/wireguard/wg0.conf << END
#DEPAN Username : $Username | Expired : $exp
[Peer]
Publickey = ${User_PUB_Key}
PresharedKey = ${User_Preshared_Key}
AllowedIPs = ${User_IP}/32
#BELAKANG Username : $Username | Expired : $exp

END

# // Make Wireguard cache folder
mkdir -p /etc/wildydev21/wireguard/;
rm -rf /etc/wildydev21/wireguard/$Username;
mkdir -p /etc/wildydev21/wireguard/$Username;

# // Restarting Service & Copy Client data to webserver
systemctl restart "wg-quick@wg0";
sysctl -p
cp /etc/wildydev21/wireguard-cache.tmp /etc/wildydev21/webserver/wg-client/${Username}.conf;

# // Clear
clear;

# // Detail
echo -e "Create From Panel | Wireguard" | tee -a /etc/wildydev21/shadowsocks/${Username}/config.log;
echo -e "===============================" | tee -a /etc/wildydev21/wireguard/${Username}/config.log;
echo -e " Username    = ${Username}" | tee -a /etc/wildydev21/wireguard/${Username}/config.log;
echo -e " IP          = ${IP}" | tee -a /etc/wildydev21/wireguard/${Username}/config.log;
echo -e " Address     = ${Domain}" | tee -a /etc/wildydev21/wireguard/${Username}/config.log;
echo -e "===============================" | tee -a /etc/wildydev21/wireguard/${Username}/config.log;
echo -e " Config File = http://${IP}:85/wg-client/${Username}.conf" | tee -a /etc/wildydev21/wireguard/${Username}/config.log;
echo -e "===============================" | tee -a /etc/wildydev21/wireguard/${Username}/config.log;
echo -e " Created     = ${hariini}" | tee -a /etc/wildydev21/wireguard/${Username}/config.log;
echo -e " Expired     = ${exp}";
echo -e "===============================";