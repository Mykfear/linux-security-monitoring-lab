# Linux Security Monitoring & Authentication Investigation Lab

A hands-on cybersecurity lab focused on Linux security monitoring, authentication investigation, SSH activity, sudo activity, SIEM log analysis, detection engineering, and SOC-style incident investigation using Kali Linux and Splunk Enterprise.

> **Project Status:** Completed — Linux security monitoring, Splunk SIEM integration, detection, investigation, and SOC dashboard development.
> **Current Focus:** Expanding detection capabilities, improving security automation, and documenting SOC investigation workflows.

---

## 📌 Project Overview

This project was created to develop practical skills relevant to an entry-level **SOC Analyst / Cybersecurity Analyst** role.

The lab uses Kali Linux as a security monitoring environment and Splunk Enterprise as the SIEM platform for collecting, searching, analyzing, and visualizing security-related events.

The project includes controlled authentication testing, Linux log collection, SSH monitoring, sudo activity analysis, security-event detection, timeline investigation, and incident documentation.

The investigation and monitoring workflow focuses on:

* Linux system logging
* SSH authentication monitoring
* Failed authentication detection
* Successful authentication detection
* Invalid-user detection
* Sudo activity monitoring
* Security event filtering
* Event correlation
* Timeline analysis
* Source and username investigation
* SIEM log ingestion
* Splunk SPL queries
* SOC dashboard development
* Incident documentation

---

## 🎯 Objectives

The objectives of this project were to:

* Understand how Linux records security-related events.
* Investigate Linux security logs using `journalctl`.
* Monitor SSH authentication activity.
* Generate controlled authentication events.
* Detect invalid-user authentication activity.
* Investigate usernames, timestamps, and source addresses.
* Analyze sudo activity.
* Build security-event timelines.
* Ingest Linux authentication logs into Splunk Enterprise.
* Develop Splunk searches for security investigations.
* Extract useful fields from authentication events.
* Investigate repeated authentication activity.
* Observe SSH defensive responses to repeated invalid-user activity.
* Build a SOC-style security monitoring dashboard.
* Document a controlled security investigation.
* Practice an end-to-end SOC investigation workflow.

---

## 🖥️ Lab Environment

| Component | Configuration |
|---|---|
| Operating System | Kali Linux |
| Virtualization | VMware |
| Host Laptop | HP EliteBook 820 G4 |
| Physical RAM | 12 GB |
| RAM Allocated to Kali | 6 GB |
| Storage | HDD |
| Kali Disk | 79 GB |
| CPU Allocated | 4 cores |
| Architecture | x86_64 |

---

## 🛠️ Tools & Technologies

### Operating System & Infrastructure

* Kali Linux
* VMware
* Docker
* OpenSSH

### Linux Security Monitoring

* systemd-journald
* journalctl
* systemctl
* ss
* grep
* Linux authentication logs
* `/var/log/auth.log`

### SIEM & Detection

* Splunk Enterprise
* SPL (Search Processing Language)
* SIEM log ingestion
* Authentication event detection
* SSH activity investigation
* Security event correlation
* Timeline analysis
* Field extraction using `rex`
* SOC dashboard development
* Splunk alerting concepts

### Scripting

* Bash
* Python 3

---

## 📊 Splunk SIEM Integration

Splunk Enterprise was deployed locally on the Kali Linux system to provide SIEM capabilities.

Linux authentication logs from `/var/log/auth.log` were ingested into Splunk using the `linux_secure` sourcetype.

The project used Splunk to:

* Collect authentication events.
* Search security-relevant events.
* Filter invalid-user activity.
* Extract usernames and source addresses.
* Analyze event timestamps.
* Investigate repeated authentication attempts.
* Monitor SSH activity.
* Analyze sudo activity.
* Visualize security events through a SOC dashboard.

---

## 🔎 Detection & Investigation

A controlled SSH authentication test was performed using a nonexistent account named `fakeuser`.

The test generated invalid-user authentication events that were collected by Splunk.

The primary detection query was:

    index=* "Invalid user" earliest=-1h

The investigation then extracted the targeted username and source address using:

    index=* "Invalid user" earliest=-1h
    | rex "Invalid user (?<target_user>\S+) from (?<src_ip>\S+)"
    | search target_user=*
    | stats count earliest(_time) as first_seen latest(_time) as last_seen by target_user src_ip
    | convert ctime(first_seen) ctime(last_seen)

The investigation identified:

| Field | Result |
|---|---|
| Target User | `fakeuser` |
| Source Address | `::1` |
| Matching Events | 4 |
| Host | `kali` |

The `::1` address is the IPv6 loopback address, indicating that the authentication activity originated locally within the laboratory environment.

---

## 🛡️ SSH Defensive Response

During the controlled authentication test, the SSH service responded to repeated invalid-user activity by applying a connection penalty.

The investigation identified:

* SSH penalty events.
* Dropped SSH connections.
* Repeated invalid-user authentication events.

The penalty events were investigated in Splunk using:

    index=* "penalty" earliest=-1h
    | stats count by host

Dropped SSH connections were investigated using:

    index=* "drop connection" earliest=-1h
    | stats count by host

These searches provided additional visibility into the SSH service's defensive response.

---

## 📈 SOC Security Monitoring Dashboard

A Splunk SOC dashboard was created to visualize authentication and security activity.

The dashboard contains panels for:

1. Failed Login Attempts Over Time
2. Top Source IPs for Failed Logins
3. Successful vs. Failed Login Ratio
4. Brute Force Detection Summary
5. Sudo Command Activity

Dashboard evidence is available in:

`screenshots/soc_security_monitoring_dashboard-2026-09-24.pdf`

---

## 🚨 Incident Investigation

The controlled SSH authentication activity was documented as a security incident investigation.

### Incident

**Incident ID:** SOC-LAB-001

**Incident Title:** Simulated SSH Invalid-User Authentication Activity

**Environment:** Kali Linux / Splunk Enterprise

**Status:** Closed — Controlled Lab Simulation

### Findings

* Repeated SSH authentication attempts were observed.
* The targeted account was `fakeuser`.
* The source address was `::1`.
* The source was the local IPv6 loopback address.
* Splunk successfully collected the authentication events.
* SSH applied a connection penalty.
* Several subsequent connections were dropped.
* No successful authentication was identified.
* No privilege escalation or system compromise was observed.

The complete incident report is available at:

`reports/SOC-Incident-Report-SSH-Authentication.md`

---

## 🔄 SOC Investigation Workflow

The project demonstrates the following workflow:

    Generate
       ↓
    Detect
       ↓
    Collect
       ↓
    Search
       ↓
    Analyze
       ↓
    Investigate
       ↓
    Document

This workflow demonstrates how a SOC analyst can move from raw security events to an investigated and documented security finding.

---

## 📁 Project Structure

    linux-security-monitoring-lab/
    │
    ├── alerts/
    │   ├── authentication_failure_*.log
    │   ├── security_alert_*.log
    │   └── ssh_bruteforce_*.log
    │
    ├── configs/
    │
    ├── logs/
    │   └── security_log_*.log
    │
    ├── reports/
    │   └── SOC-Incident-Report-SSH-Authentication.md
    │
    ├── screenshots/
    │   └── soc_security_monitoring_dashboard-2026-09-24.pdf
    │
    ├── scripts/
    │   ├── detection_engine.sh
    │   ├── detection_engine_backup.sh
    │   ├── log_collector.sh
    │   ├── network_monitor.sh
    │   └── system_info.sh
    │
    ├── .gitignore
    └── README.md

---

## 🧪 Controlled Testing

All authentication testing in this project was performed in a controlled laboratory environment.

The SSH activity documented in the incident report was generated locally against the Kali Linux system.

The test was designed to evaluate:

* Security event generation.
* Log collection.
* SIEM visibility.
* Detection.
* Investigation.
* Defensive response.
* Incident documentation.

No production systems or external targets were used.

---

## 📚 Skills Demonstrated

This project demonstrates practical experience with:

* Linux security monitoring
* SOC investigation methodology
* Splunk Enterprise
* SIEM log ingestion
* SPL
* Authentication event analysis
* SSH monitoring
* Linux authentication logs
* Security event detection
* Regular-expression field extraction
* Timeline analysis
* Event correlation
* Incident documentation
* Bash scripting
* Python
* Linux command-line tools
* Security monitoring dashboards
* Controlled security testing

---

## 📄 Project Evidence

### Incident Report

`reports/SOC-Incident-Report-SSH-Authentication.md`

### Splunk SOC Dashboard

`screenshots/soc_security_monitoring_dashboard-2026-09-24.pdf`

---

## ⚠️ Disclaimer

This project was created for educational and portfolio purposes.

All security testing was performed in a controlled laboratory environment using systems owned or operated for the purpose of the exercise.

No unauthorized systems were targeted.

---

## 👤 Author

**EKENE MICHAEL IKENGA**

Cybersecurity Analyst | IT Support | Graphic Designer

GitHub: `https://github.com/Mykfear`
