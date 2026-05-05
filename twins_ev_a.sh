#!/bin/bash
# ==============================================================================
# SYSTEM: Twins_EV_A (MICRO-KERNEL ARCHITECTURE)
# VERSION: 14.3.0-RESILIENT | AUTHOR: viruszero
# FIX: Handle "No space left on device" & Write Errors
# ==============================================================================

set -Euo pipefail # شيلنا الـ -e عشان السكربت ميفصلش لو أمر فشل بسبب المساحة

# [1] KERNEL REGISTRY
readonly VZ_VERSION="14.3.0"
declare -A PID_TABLE
declare -A EVENT_REGISTRY
declare -A STATE_RULES
CURRENT_STATE="BOOT"

# الألوان
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; 
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'; NC='\033[0m'

# [2] STATE MACHINE CONFIG
STATE_RULES["BOOT"]="READY"
STATE_RULES["READY"]="EXECUTION"
STATE_RULES["EXECUTION"]="MONITORING"
STATE_RULES["MONITORING"]="CLEANUP"
STATE_RULES["CLEANUP"]="READY"

# [3] RESILIENT LOGGING (معدل لمنع الانهيار)
on_state_log() { 
    local log_file="./logs/system.log"
    # التأكد من وجود المجلد أولاً
    [[ ! -d "./logs" ]] && mkdir -p ./logs 2>/dev/null || true
    
    # محاولة الكتابة مع تجاهل الخطأ لو الهارد مليان
    {
        echo -e "[$(date +%T)] STATE: $1" >> "$log_file"
    } 2>/dev/null || echo -e "${RED}[!] Storage Alert: System Log full/unwritable${NC}"
}

# [4] KERNEL UI: THE BANNER
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "  __      _______ _____  _    _  _____ ______ ______ _____   ____  "
    echo "  \ \    / /_   _|  __ \| |  | |/ ____|___  /|  ____|  __ \ / __ \ "
    echo "   \ \  / /  | | | |__) | |  | | (___    / / | |__  | |__) | |  | |"
    echo "    \ \/ /   | | |  _  /| |  | |\___ \  / /  |  __| |  _  /| |  | |"
    echo "     \  /   _| |_| | \ \| |__| |____) |/ /__ | |____| | \ \| |__| |"
    echo "      \/   |_____|_|  \_\\____/|_____//_____||______|_|  \_\\____/ "
    echo -e "                                         ${MAGENTA}CORE ARCHITECTURE v$VZ_VERSION${NC}"
    echo -e "${BLUE}  ============================================================${NC}"
    echo -e "  [+] Kernel: ${GREEN}ONLINE${NC} | State: ${YELLOW}$CURRENT_STATE${NC} | User: ${RED}viruszero${NC}"
    echo -e "${BLUE}  ============================================================${NC}"
}

# [5] EVENT BUS & PROCESS ORCHESTRATOR
subscribe() { EVENT_REGISTRY["$1"]+="$2 "; }
emit() { for h in ${EVENT_REGISTRY["$1"]:-}; do $h "$2"; done; }

change_state() {
    local target=$1
    if [[ "${STATE_RULES[$CURRENT_STATE]:-}" == "$target" ]] || [[ "$target" == "CLEANUP" ]]; then
        on_state_log "$CURRENT_STATE -> $target"
        CURRENT_STATE=$target
    else
        echo -e "${RED}[!] Illegal Transition Attempted${NC}"
    fi
}

spawn_task() {
    local name=$1; local cmd=$2
    $cmd & 
    local pid=$!
    PID_TABLE["$name"]=$pid
    on_state_log "SPAWN: $name (PID: $pid)"
}

# [6] SAFETY & CLEANUP
cleanup() {
    echo -e "\n${YELLOW}[*] System Cleanup in progress...${NC}"
    for p in "${!PID_TABLE[@]}"; do kill "${PID_TABLE[$p]}" 2>/dev/null || true; done
    # مسح الملفات المؤقتة لو وجدت لتقليل الزحام
    sudo rm -f /tmp/twins_ev_*.tmp 2>/dev/null || true
}
trap cleanup SIGINT SIGTERM EXIT

# [7] THE MAIN LOOP
main() {
    # فحص المساحة قبل البدء (تنبيه فقط)
    local space=$(df / --output=pcent | tail -1 | tr -dc '0-9')
    [[ "$space" -gt 95 ]] && echo -e "${RED}[WARNING] Disk space is critically low ($space%)${NC}"

    [[ $EUID -ne 0 ]] && { echo "ROOT REQUIRED"; exit 1; }
    mkdir -p logs modules 2>/dev/null || true
    change_state "READY"
    
    while true; do
        show_banner
        echo -e "${GREEN}1)${NC} Execute Module (Safe Mode)"
        echo -e "${GREEN}2)${NC} Emergency Reset"
        echo -e "${GREEN}3)${NC} Terminate Kernel"
        echo -ne "\n${MAGENTA}vz-core@kali:~$ ${NC}"
        read -r choice || choice=""
        
        case $choice in
            1) change_state "EXECUTION"
               spawn_task "Engine_Core" "sleep 100"
               change_state "MONITORING" ;;
            2) cleanup; PID_TABLE=(); change_state "READY" ;;
            3) exit 0 ;;
            *) sleep 0.5 ;;
        esac
    done
}

main
