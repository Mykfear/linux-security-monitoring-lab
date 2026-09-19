#!/bin/bash

echo "======================================"
echo " Linux Security Monitoring Lab"
echo " Network Monitoring"
echo "======================================"

echo ""
echo "[+] Collection Time:"
date

echo ""
echo "========== NETWORK INTERFACES =========="

echo ""
echo "[+] Network Interfaces:"
ip -brief addr

echo ""
echo "========== ROUTING INFORMATION =========="

echo ""
echo "[+] Routing Table:"
ip route

echo ""
echo "========== LISTENING SERVICES =========="

echo ""
echo "[+] Listening TCP/UDP Ports:"
sudo ss -tulnp

echo ""
echo "[+] Listening Port Count:"
sudo ss -tulnp | tail -n +2 | wc -l

echo ""
echo "========== ACTIVE CONNECTIONS =========="

echo ""
echo "[+] Active Network Connections:"
sudo ss -tunap

echo ""
echo "[+] Active Connection Count:"
sudo ss -tunap | tail -n +2 | wc -l

echo ""
echo "========== NETWORK PROCESSES =========="

echo ""
echo "[+] Processes Using Network Connections:"
sudo lsof -i -n -P 2>/dev/null | head -n 30

echo ""
echo "======================================"
echo " Network Monitoring Complete"
echo "======================================"
