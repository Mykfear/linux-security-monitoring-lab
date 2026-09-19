#!/bin/bash

echo "======================================"
echo " Linux Security Monitoring Lab"
echo " System Information"
echo "======================================"

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
echo "======================================"
echo " Collection Complete"
echo "======================================"
