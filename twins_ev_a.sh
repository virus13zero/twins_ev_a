#!/bin/bash
# ==============================================================================
# SYSTEM: Twins_EV_A (MICRO-KERNEL ARCHITECTURE)
# VERSION: 14.4.0-DASHBOARD | AUTHOR: viruszero
# FEATURE: Real-time Process Radar & Health Monitor
# ==============================================================================

set -Euo pipefail 

# [1] KERNEL REGISTRY
readonly VZ_VERSION="14.4.0"
declare -A PID_TABLE
declare -A EVENT_REGISTRY
declare -A STATE_RULES
CURRENT_STATE="BOOT"

# الألوان الاحترافية
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; 
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'; NC='\033[0m'

# [2] STATE MACHINE CONFIG
STATE_RULES["BOOT"]="READY"
STATE_RULES["READY"]="EXECUTION"
STATE_RULES["EXECUTION"]="MONITORING"
STATE_RULES["MONITORING"]="CLEANUP"
STATE_RULES["CLEANUP"]="READY"

# [3] RESILIENT LOGGING
on_state_log() { 
    local log_file="./logs/system.log"
    [[ ! -d "./logs" ]] && mkdir -p ./logs 2>/dev/null || true
    { echo -e "[$(date +%T)] STATE: $1" >> "$log_file"; } 2>/dev/null || true
}

# [4] KERNEL UI: THE LIVE DASHBOARD (التعديل الجوهري هنا)
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
    
    # --- Process Radar (الرادار الحي) ---
    echo -e "${BLUE}  ==================== ACTIVE PROCESSES ======================${NC}"
    if [ ${#PID_TABLE[@]} -eq 0 ]; then
        echo -e "  [!] No active tasks in background."
    else
        for task in "${!PID_TABLE[@]}"; do
            local pid=${PID_TABLE[$task]}
            if ps -p $pid > /dev/null 2>&1; then
                echo -e "  [${GREEN}✔${NC}] ${CYAN}$task${NC} (PID: $pid) -> ${GREEN}RUNNING${NC}"
            else
                echo -e "  [${RED}✘${NC}] ${CYAN}$task${NC} (PID: $pid) -> ${RED}TERMINATED${NC}"
                unset PID_TABLE["$task"] # تنظيف الجدول من العمليات الميتة
            fi
        done
    fi
    echo -e "${BLUE}  ============================================================${NC}"
}

# [5] CORE ENGINE LOGIC
change_state() {
    local target=$1
    if [[ "${STATE_RULES[$CURRENT_STATE]:-}" == "$target" ]] || [[ "$target" == "CLEANUP" ]]; then
        on_state_log "$CURRENT_STATE -> $target"
        CURRENT_STATE=$target
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
    for p in "${!PID_TABLE[@]}"; do kill "${PID_TABLE[$p]}" 2>/dev/null || true; done
    PID_TABLE=()
    on_state_log "SYSTEM_RESET"
}
trap cleanup SIGINT SIGTERM EXIT

# [7] THE MAIN LOOP
main() {
    [[ $EUID -ne 0 ]] && { echo "ROOT REQUIRED"; exit 1; }
    mkdir -p logs modules 2>/dev/null || true
    change_state "READY"
    
    while true; do
        show_banner
        echo -e "${GREEN}1)${NC} Execute Module (Safe Engine)"
        echo -e "${GREEN}2)${NC} Emergency Reset (Cleanup)"
        echo -e "${GREEN}3)${NC} Terminate Kernel"
        echo -ne "\n${MAGENTA}vz-core@kali:~$ ${NC}"
        read -r choice || choice=""
        
        case $choice in
            1) change_state "EXECUTION"
               # بنشغل عملية وهمية للتجربة لمدة 60 ثانية
               spawn_task "Engine_Core" "sleep 60"
               change_state "MONITORING" ;;
            2) cleanup; change_state "READY" ;;
            3) exit 0 ;;
            *) sleep 0.2 ;;
        esac
    done
}

main
