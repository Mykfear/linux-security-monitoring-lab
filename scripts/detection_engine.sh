#!/bin/bash

echo "======================================"
echo " Linux Security Monitoring Lab"
echo " Detection Engine"
echo "======================================"

ALERT_DIR="alerts"

mkdir -p "$ALERT_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

AUTH_ALERT_FILE="$ALERT_DIR/authentication_failure_$TIMESTAMP.log"
SSH_ALERT_FILE="$ALERT_DIR/ssh_bruteforce_$TIMESTAMP.log"

# Detection settings
SSH_THRESHOLD=5
SSH_TIME_WINDOW="10 minutes"

echo ""
echo "[+] Detection started at: $(date)"


# ==================================================
# RULE 1: GENERAL AUTHENTICATION FAILURE DETECTION
# ==================================================

echo ""
echo "========== RULE 1: AUTHENTICATION FAILURES =========="

ALL_AUTH_FAILURES=$(sudo journalctl --no-pager | grep -Ei \
"authentication failure|failed password|failed login")

AUTH_FAILURE_COUNT=$(echo "$ALL_AUTH_FAILURES" | grep -c .)

echo ""
echo "[+] Total authentication failures detected: $AUTH_FAILURE_COUNT"

if [ "$AUTH_FAILURE_COUNT" -gt 0 ]; then

    echo ""
    echo "🚨 AUTHENTICATION FAILURE ALERT"
    echo "[+] Authentication failures were detected."
    echo "[+] These events require investigation."

    {
        echo "======================================"
        echo " AUTHENTICATION FAILURE ALERT"
        echo " Linux Security Monitoring Lab"
        echo "======================================"
        echo "Alert Type: General Authentication Failure"
        echo "Detection Time: $(date)"
        echo "Hostname: $(hostname)"
        echo "Total Authentication Failures: $AUTH_FAILURE_COUNT"
        echo ""
        echo "========== RECENT AUTHENTICATION FAILURES =========="
        echo "$ALL_AUTH_FAILURES" | tail -n 10
        echo ""
        echo "========== INVESTIGATION =========="
        echo "1. Identify the authentication service."
        echo "2. Identify the affected username."
        echo "3. Identify the source address when available."
        echo "4. Determine whether the activity is legitimate."
        echo "5. Check for repeated or unusual activity."
        echo ""
        echo "========== ALERT COMPLETE =========="
    } > "$AUTH_ALERT_FILE"

    echo ""
    echo "[+] Authentication alert saved to:"
    echo "    $AUTH_ALERT_FILE"

else

    echo "[+] No authentication failures detected."

fi


# ==================================================
# RULE 2: SSH BRUTE-FORCE DETECTION
# ==================================================

echo ""
echo "========== RULE 2: SSH BRUTE-FORCE DETECTION =========="

echo ""
echo "[+] Detection window: Last $SSH_TIME_WINDOW"
echo "[+] Threshold: $SSH_THRESHOLD failed attempts"
echo "[+] Detection method: Same source IP"

# Collect failed SSH password attempts from the last 10 minutes
SSH_FAILURES=$(sudo journalctl \
    --since "$SSH_TIME_WINDOW ago" \
    --no-pager | grep -Ei \
    "sshd.*Failed password|Failed password.*sshd")

SSH_FAILURE_COUNT=$(echo "$SSH_FAILURES" | grep -c .)

echo ""
echo "[+] Failed SSH authentication attempts in time window: $SSH_FAILURE_COUNT"

if [ "$SSH_FAILURE_COUNT" -eq 0 ]; then

    echo "[+] No failed SSH authentication attempts detected."

else

    echo ""
    echo "[+] Failed SSH attempts detected:"
    echo "$SSH_FAILURES"

    # Extract source IP addresses and count occurrences
    SOURCE_IPS=$(echo "$SSH_FAILURES" | \
        grep -oE 'from ([0-9]{1,3}\.){3}[0-9]{1,3}' | \
        awk '{print $2}' | sort | uniq)

    BRUTE_FORCE_DETECTED=false

    for SOURCE_IP in $SOURCE_IPS
    do

        SOURCE_COUNT=$(echo "$SSH_FAILURES" | \
            grep -c "from $SOURCE_IP")

        echo ""
        echo "[+] Source IP: $SOURCE_IP"
        echo "[+] Failed attempts from this IP: $SOURCE_COUNT"

        if [ "$SOURCE_COUNT" -ge "$SSH_THRESHOLD" ]; then

            BRUTE_FORCE_DETECTED=true

            echo ""
            echo "🚨 POSSIBLE SSH BRUTE-FORCE ALERT"
            echo "[+] Source IP: $SOURCE_IP"
            echo "[+] Failed attempts: $SOURCE_COUNT"
            echo "[+] Threshold: $SSH_THRESHOLD"
            echo "[+] Time window: $SSH_TIME_WINDOW"

            {
                echo "======================================"
                echo " POSSIBLE SSH BRUTE-FORCE ALERT"
                echo " Linux Security Monitoring Lab"
                echo "======================================"
                echo "Alert Type: Possible SSH Brute-Force Activity"
                echo "Detection Time: $(date)"
                echo "Hostname: $(hostname)"
                echo "Source IP: $SOURCE_IP"
                echo "Failed SSH Attempts: $SOURCE_COUNT"
                echo "Detection Threshold: $SSH_THRESHOLD"
                echo "Detection Window: $SSH_TIME_WINDOW"
                echo ""
                echo "========== SSH FAILURE EVIDENCE =========="
                echo "$SSH_FAILURES" | grep "from $SOURCE_IP"
                echo ""
                echo "========== INVESTIGATION =========="
                echo "1. Identify the source IP address."
                echo "2. Identify the targeted username."
                echo "3. Determine whether the source is local or remote."
                echo "4. Review the timing and frequency of attempts."
                echo "5. Check for successful authentication after failures."
                echo "6. Determine whether the activity represents legitimate or suspicious behavior."
                echo "7. Check whether the source IP appears in other security logs."
                echo ""
                echo "========== ALERT COMPLETE =========="
            } > "$SSH_ALERT_FILE"

            echo ""
            echo "[+] SSH brute-force alert saved to:"
            echo "    $SSH_ALERT_FILE"

        fi

    done

    if [ "$BRUTE_FORCE_DETECTED" = false ]; then

        echo ""
        echo "[+] SSH brute-force threshold not reached."
        echo "[+] No SSH brute-force alert generated."

    fi

fi


# ==================================================
# FINAL DETECTION SUMMARY
# ==================================================

echo ""
echo "========== DETECTION SUMMARY =========="

echo "[+] General authentication failures: $AUTH_FAILURE_COUNT"
echo "[+] SSH failures in last $SSH_TIME_WINDOW: $SSH_FAILURE_COUNT"

if [ "$AUTH_FAILURE_COUNT" -gt 0 ]; then
    echo "[+] Authentication alert: CREATED"
else
    echo "[+] Authentication alert: NOT CREATED"
fi

if [ "$BRUTE_FORCE_DETECTED" = true ]; then
    echo "[+] SSH brute-force alert: CREATED"
else
    echo "[+] SSH brute-force alert: NOT CREATED"
fi

echo ""
echo "======================================"
echo " Detection Complete"
echo "======================================"
