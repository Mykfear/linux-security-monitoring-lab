#!/bin/bash

echo "======================================"
echo " Linux Security Monitoring Lab"
echo " Security Monitoring Dashboard"
echo "======================================"

echo ""
echo "========== SYSTEM INFORMATION =========="

echo ""
echo "[+] Hostname:"
hostname

echo ""
echo "[+] Current User:"
whoami

echo ""
echo "[+] Operating System:"
cat /etc/os-release | grep PRETTY_NAME

echo ""
echo "[+] Kernel:"
uname -r

echo ""
echo "[+] IP Addresses:"
ip -brief addr

echo ""
echo "[+] Default Route:"
ip route | grep default

echo ""
echo "[+] Disk Usage:"
df -h /

echo ""
echo "[+] Memory Usage:"
free -h

echo ""
echo "========== LOGIN MONITORING =========="

echo ""
echo "[+] Recent Successful Logins:"
last -n 10

echo ""
echo "[+] Recent Failed Authentication Attempts:"

FAILED_LOGINS=$(sudo journalctl _SYSTEMD_UNIT=ssh.service --no-pager | grep -i "Failed password")

if [ -z "$FAILED_LOGINS" ]; then
    echo "No failed SSH login attempts detected."
else
    echo "$FAILED_LOGINS" | tail -n 10
fi

echo ""
echo "[+] Failed Login Count:"
echo "$FAILED_LOGINS" | wc -l

echo ""
echo "========== SECURITY MONITORING SUMMARY =========="

echo ""
echo "[+] Monitoring completed successfully."
echo "[+] System information collected."
echo "[+] Login activity checked."
echo "[+] Authentication failures checked."

echo ""
echo "======================================"
echo " Collection Complete"
echo "======================================"
