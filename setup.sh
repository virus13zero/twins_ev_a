#!/bin/bash
# ==============================================================================
# INSTALLER: Twins_EV_A Setup Utility
# TARGET: Debian/Kali Linux Based Systems
# ==============================================================================

# الألوان عشان يبقى شكله شيك وهو بيسطب
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}[*] Initializing Twins_EV_A Deployment...${NC}"

# 1. تحديث النظام
echo -e "${CYAN}[*] Updating package lists...${NC}"
sudo apt update -y

# 2. تنصيب الأدوات (الأصلية + الجديدة للمراقب)
echo -e "${CYAN}[*] Installing Core Dependencies...${NC}"
sudo apt install -y aircrack-ng dnsmasq tshark iptables xterm wireless-tools \
                    iproute2 procps util-linux

# 3. ضبط الصلاحيات (باسم الملف الجديد Twins_EV_A.sh)
echo -e "${CYAN}[*] Configuring Executable Permissions...${NC}"
chmod +x twins_ev_a.sh

# 4. إنشاء المجلدات الضرورية للنظام (لضمان عمل الـ Kernel)
mkdir -p logs modules vault configuration

echo -e "${GREEN}[✔] Setup Complete!${NC}"
echo -e "${GREEN}[!] You can now start the Kernel using: ${RED}sudo ./twins_ev_a.sh${NC}"
