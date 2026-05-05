#!/bin/bash
# ==============================================================================
# SYSTEM: Twins_EV_A (MICRO-KERNEL ARCHITECTURE)
# REPO: https://github.com/virus13zero/twins_ev_a
# VERSION: 14.2.0-STABLE | AUTHOR: viruszero
# ==============================================================================

set -Eeuo pipefail

# [1] KERNEL REGISTRY
readonly VZ_VERSION="14.2.0"
declare -A PID_TABLE       # Process Tracking
declare -A EVENT_REGISTRY  # Event Bus
declare -A STATE_RULES     # FSM Logic
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

# [3] KERNEL UI: THE BANNER
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

# [4] EVENT BUS (PUB/SUB)
subscribe() { EVENT_REGISTRY["$1"]+="$2 "; }
emit() {
    for handler in ${EVENT_REGISTRY["$1"]:-}; do $handler "$2"; done
}

# [5] CORE ENGINE LOGIC
change_state() {
    local target=$1
    if [[ "${STATE_RULES[$CURRENT_STATE]:-}" == "$target" ]] || [[ "$target" == "CLEANUP" ]]; then
        emit "state_changed" "$CURRENT_STATE -> $target"
        CURRENT_STATE=$target
    else
        emit "kernel_panic" "Illegal Transition: $CURRENT_STATE to $target"
        exit 1
    fi
}

# [6] PROCESS ORCHESTRATOR
spawn_task() {
    local name=$1; local cmd=$2
    $cmd & 
    local pid=$!
    PID_TABLE["$name"]=$pid
    emit "process_spawned" "$name (PID: $pid)"
}

# [7] SAFETY & CLEANUP
cleanup() {
    emit "shutdown" "Purging System Traces"
    for p in "${!PID_TABLE[@]}"; do kill "${PID_TABLE[$p]}" 2>/dev/null || true; done
    sudo iptables -F && sudo iptables -t nat -F
}
trap cleanup SIGINT SIGTERM EXIT

# [8] THE MAIN RUNTIME LOOP
main() {
    [[ $EUID -ne 0 ]] && { echo "ROOT REQUIRED"; exit 1; }
    mkdir -p logs modules
    change_state "READY"
    
    while true; do
        show_banner
        echo -e "${GREEN}1)${NC} Execute Module (System Engine)"
        echo -e "${GREEN}2)${NC} Emergency Reset (State: CLEANUP)"
        echo -e "${GREEN}3)${NC} Terminate Kernel"
        echo -ne "\n${MAGENTA}vz-core@linux:~$ ${NC}"
        read -r choice
        
        case $choice in
            1) change_state "EXECUTION"
               spawn_task "Diagnostics" "sleep 100"
               change_state "MONITORING" ;;
            2) cleanup; PID_TABLE=(); change_state "READY" ;;
            3) exit 0 ;;
            *) echo "Invalid Command"; sleep 1 ;;
        esac
    done
}

main
