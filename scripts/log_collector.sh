#!/bin/bash

echo "======================================"
echo " Linux Security Monitoring Lab"
echo " Log Collection"
echo "======================================"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_DIR="logs"
OUTPUT_FILE="$LOG_DIR/security_log_$TIMESTAMP.log"

mkdir -p "$LOG_DIR"

echo "[+] Collection started at: $(date)"
echo "[+] Output file: $OUTPUT_FILE"

{
    echo "======================================"
    echo " Linux Security Monitoring Log"
    echo " Collection Time: $(date)"
    echo " Hostname: $(hostname)"
    echo "======================================"

    echo ""
    echo "========== FAILED AUTHENTICATION ATTEMPTS =========="

    sudo journalctl --no-pager | grep -Ei "failed password|authentication failure|failed login" | tail -n 20

    echo ""
    echo "========== SSH ACTIVITY =========="

    sudo journalctl -u ssh --no-pager -n 20

    echo ""
    echo "========== RECENT SYSTEM EVENTS =========="

    sudo journalctl --no-pager -n 30

    echo ""
    echo "========== ACTIVE USERS =========="

    who

    echo ""
    echo "========== LOG COLLECTION COMPLETE =========="
} > "$OUTPUT_FILE"

echo ""
echo "[+] Security log collection completed."
echo "[+] Log saved to: $OUTPUT_FILE"

echo "======================================"
