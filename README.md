# Linux Security Monitoring & Authentication Investigation Lab

A hands-on cybersecurity mini-project focused on Linux security monitoring, authentication investigation, SSH activity, sudo activity, and SOC-style log analysis using Kali Linux.

> **Project Status:** Phase 1 completed — Linux security monitoring and authentication investigation.
> **Next Phase:** Splunk SIEM integration, detection, alerting, and dashboard development.

---

## 📌 Project Overview

This project was created to develop practical skills relevant to an entry-level **SOC Analyst / Cybersecurity Analyst** role.

The lab involved generating controlled authentication events on a Kali Linux system, collecting system telemetry using `systemd-journald`, filtering security-relevant events, and investigating the resulting logs from a SOC analyst perspective.

The investigation focused on:

* Linux system logging
* SSH authentication monitoring
* Failed authentication detection
* Successful authentication detection
* Sudo activity
* Security event filtering
* Event correlation
* Timeline analysis
* Distinguishing normal activity from potentially suspicious activity

---

## 🎯 Objectives

The objectives of this project were to:

* Understand how Linux records security-related events.
* Learn how to investigate logs using `journalctl`.
* Monitor SSH authentication activity.
* Generate controlled failed SSH authentication events.
* Generate controlled successful SSH authentication events.
* Investigate usernames, timestamps, source addresses, and ports.
* Analyze sudo activity.
* Build a basic security-event timeline.
* Practice a SOC-style investigation workflow.
* Prepare the environment for future SIEM integration.

---

## 🖥️ Lab Environment

| Component             | Configuration       |
| --------------------- | ------------------- |
| Operating System      | Kali Linux          |
| Virtualization        | VMware              |
| Host Laptop           | HP EliteBook 820 G4 |
| Physical RAM          | 12 GB               |
| RAM Allocated to Kali | 6 GB                |
| Storage               | HDD                 |
| Kali Disk             | 79 GB               |
| CPU Allocated         | 4 cores             |
| Architecture          | x86_64              |

---

## 🛠️ Tools & Technologies

* Kali Linux
* VMware
* systemd-journald
* journalctl
* OpenSSH
* systemctl
* ss
* grep
* Docker
* Python 3

### Planned

* Splunk Enterprise
* SPL (Search Processing Language)
* SIEM-based detection
* Splunk alerts
* SOC dashboard
* Python security automation

---

# 🔎 Investigation Process

## 1. Establishing a Log Baseline

The first step was to inspect recent system activity.

```bash
journalctl --no-pager -n 20
```

### Purpose

This command displays the most recent 20 journal entries.

It was used to establish a baseline of normal system activity before focusing on security events.

Observed activity included normal system services, CRON jobs, power-management events, and other system processes.

---

## 2. Investigating Sudo Activity

Sudo-related events were searched using:

```bash
journalctl --no-pager -o short-iso | grep -i sudo
```

### Purpose

This searches the system journal for events containing `sudo`.

The investigation identified administrative activities involving commands such as:

* `whoami`
* Docker configuration
* Nmap
* Git
* Python
* Package management commands

A failed sudo authentication event was also identified:

```text
pam_unix(sudo:auth): conversation failed
auth could not identify password for [kali]
```

### SOC Interpretation

A failed authentication event is security-relevant, but it should not automatically be classified as malicious.

The analyst should consider:

* Who performed the action?
* When did it occur?
* What command was being executed?
* Was the activity expected?
* Were there repeated failures?

---

# 🔐 SSH Investigation

## 3. Searching SSH Activity

SSH-related events were investigated using:

```bash
journalctl --no-pager -o short-iso | grep -i ssh
```

A more targeted search was then performed:

```bash
journalctl --no-pager -o short-iso | grep -Ei "sshd|Accepted|Failed password"
```

### Purpose

The targeted search looks for:

* `sshd`
* `Accepted`
* `Failed password`

This reduced the amount of unrelated system activity and focused the investigation on SSH authentication.

---

## 4. Checking the SSH Service

The SSH service was initially found to be inactive.

It was checked using:

```bash
systemctl status ssh --no-pager
```

SSH was then started:

```bash
sudo systemctl start ssh
```

The service subsequently became active and began listening for connections.

---

## 5. Verifying Port 22

The SSH listening state was verified using:

```bash
ss -tlnp | grep ':22'
```

The system showed SSH listening on:

```text
0.0.0.0:22
[::]:22
```

This confirmed that the SSH service was listening on both IPv4 and IPv6 interfaces.

---

# 🚨 6. Controlled Failed Authentication

A controlled SSH authentication attempt was performed against the local system:

```bash
ssh kali@localhost
```

An incorrect password was intentionally entered to generate a failed authentication event.

The journal recorded events including:

```text
pam_unix(sshd:auth): authentication failure
```

and:

```text
Failed password for kali from ::1
```

### Observed Information

The event contained information such as:

| Field                 | Value  |
| --------------------- | ------ |
| Username              | kali   |
| Source Address        | ::1    |
| Protocol              | SSH    |
| Authentication Result | Failed |
| Source Port           | 60074  |

### Security Interpretation

The event represents a failed authentication attempt.

In a production environment, repeated failed attempts could require investigation for possible:

* Brute-force activity
* Password spraying
* Unauthorized access attempts
* Misconfiguration
* User error

In this lab, the event was deliberately generated for testing.

---

# ⏱️ 7. Authentication Timeout

The investigation also identified:

```text
Timeout before authentication for connection from ::1 to ::1
```

This demonstrated that a single authentication attempt can produce multiple related events.

A SOC analyst should therefore investigate the surrounding timeline rather than relying on one log entry in isolation.

---

# ✅ 8. Controlled Successful Authentication

A successful SSH login was subsequently performed.

The journal recorded:

```text
Accepted password for kali from ::1
```

Multiple successful authentication events were observed during the investigation.

The events provided information such as:

* Username
* Authentication method
* Source address
* Source port
* Timestamp

### Security Interpretation

A successful authentication event is not automatically malicious.

The analyst needs to establish whether the:

* Account is legitimate.
* Source address is expected.
* Login time is reasonable.
* Authentication method is expected.
* Activity matches known user behavior.

In this lab, the successful logins were intentionally generated by the analyst.

---

# 📊 Authentication Investigation Timeline

| Time  | Event                           | Result     |
| ----- | ------------------------------- | ---------- |
| 10:19 | SSH authentication attempt      | Failed     |
| 10:19 | Password authentication failure | Failed     |
| 10:19 | SSH authentication timeout      | Timeout    |
| 10:26 | SSH authentication              | Successful |
| 11:58 | SSH authentication              | Successful |
| 12:01 | SSH authentication              | Successful |

All authentication activity in this laboratory was generated or observed within the controlled Kali environment.

---

# 🧠 SOC Investigation Workflow

The project followed a simplified SOC investigation process:

```text
System Activity
      ↓
Log Collection
      ↓
Event Filtering
      ↓
Security Event Identification
      ↓
Timeline Construction
      ↓
Contextual Investigation
      ↓
Normal vs Suspicious Activity
      ↓
Documentation
```

This workflow forms the foundation for later SIEM-based investigations.

---

# 📚 Key Commands

### View recent journal events

```bash
journalctl --no-pager -n 20
```

Displays the latest 20 journal entries.

### Search sudo activity

```bash
journalctl --no-pager -o short-iso | grep -i sudo
```

Searches for sudo-related events.

### Search SSH authentication activity

```bash
journalctl --no-pager -o short-iso | grep -Ei "sshd|Accepted|Failed password"
```

Filters SSH authentication-related events.

### Check SSH service status

```bash
systemctl status ssh --no-pager
```

Displays the current SSH service status.

### Start SSH

```bash
sudo systemctl start ssh
```

Starts the SSH service.

### Check listening ports

```bash
ss -tlnp | grep ':22'
```

Checks whether SSH is listening on port 22.

### Generate a local SSH authentication event

```bash
ssh kali@localhost
```

Creates a local SSH authentication session for controlled testing.

---

# 🔐 Security Findings

The investigation successfully demonstrated that Linux journald can provide useful security telemetry.

The following event types were identified:

* Failed SSH authentication
* Successful SSH authentication
* SSH authentication timeout
* Sudo authentication activity
* Privileged command activity
* SSH service state
* General system activity

The observed authentication events were intentionally generated as part of the laboratory exercise and should not be interpreted as evidence of an external attack.

---

# 💡 Lessons Learned

### 1. Log Analysis

Security analysts need to understand where system logs are stored and how to filter them effectively.

### 2. Authentication Monitoring

Authentication events provide useful visibility into account activity.

### 3. Event Correlation

Multiple log entries may be associated with one activity and should be analyzed together.

### 4. Baseline Analysis

Understanding normal system behavior helps analysts identify unusual activity.

### 5. Context Matters

A failed login does not automatically mean an attack.

### 6. Documentation

A security investigation should document:

* What happened
* When it happened
* Which account was involved
* Where the activity originated
* What evidence was observed
* Whether the activity was expected

---

# 🚀 Future Improvements

The next phase of this project will introduce **Splunk Enterprise** as the SIEM platform.

Planned improvements include:

* Install Splunk Enterprise.
* Ingest Kali Linux security telemetry.
* Create a dedicated SIEM index.
* Search SSH authentication events.
* Search sudo activity.
* Develop failed-login detection.
* Generate repeated controlled authentication failures.
* Create Splunk detection rules.
* Configure alerts.
* Build a SOC dashboard.
* Add additional Linux telemetry.
* Introduce Python-based security automation.
* Document the complete investigation lifecycle.

---

# 🏗️ Planned SIEM Architecture

```text
                 KALI LINUX
                     │
                     ▼
              System Telemetry
                     │
          ┌──────────┴──────────┐
          │                     │
        SSH                    Sudo
          │                     │
          └──────────┬──────────┘
                     ▼
              SPLUNK ENTERPRISE
                     │
          ┌──────────┼──────────┐
          ▼          ▼          ▼
       Search    Detection    Alerts
          │          │          │
          └──────────┼──────────┘
                     ▼
                SOC DASHBOARD
```

---

# 📌 Project Status

### Phase 1 — Linux Security Monitoring

**Status: COMPLETED ✅**

* [x] Linux log investigation
* [x] Journald analysis
* [x] Sudo activity investigation
* [x] SSH service investigation
* [x] SSH port verification
* [x] Controlled failed authentication
* [x] Controlled successful authentication
* [x] Authentication timeline
* [x] SOC investigation workflow

### Phase 2 — SIEM Integration

**Status: PLANNED ⏳**

* [ ] Install Splunk Enterprise
* [ ] Configure log ingestion
* [ ] Create searches
* [ ] Build detections
* [ ] Configure alerts
* [ ] Build SOC dashboard
* [ ] Add automation

---

## 👨‍💻 Author

**Ekene Michael Ikenga**

Entry-Level Cybersecurity Analyst

**Focus Areas:**

* Cybersecurity
* SOC Analysis
* Security Monitoring
* Linux
* SIEM
* Network Security
* Incident Investigation
* IT Support

---

## ⚠️ Disclaimer

This project was performed in a controlled laboratory environment for educational and cybersecurity training purposes.

All authentication events were generated intentionally on the author's own virtual machine.
