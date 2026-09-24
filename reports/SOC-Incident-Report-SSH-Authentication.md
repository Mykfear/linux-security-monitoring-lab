# Security Incident Report

## Incident Title
Simulated SSH Invalid-User Authentication Activity

## Incident ID
SOC-LAB-001

## Date
September 24, 2026

## Environment
Kali Linux / Splunk Enterprise

## Host
`kali`

## Log Source
`/var/log/auth.log`

## Splunk Sourcetype
`linux_secure`

## Status
**Closed — Controlled Lab Simulation**

---

## 1. Executive Summary

A controlled SSH authentication test was performed against a Kali Linux system to evaluate the ability of Splunk to collect, detect, investigate, and visualize authentication-related security events.

The test generated repeated SSH authentication attempts using a nonexistent account named `fakeuser`.

Splunk successfully ingested the resulting authentication events from `/var/log/auth.log` and provided visibility into the activity.

The investigation identified:

- 16 events containing the `Invalid user` message.
- 4 explicit events identifying `fakeuser` as the attempted username.
- Source address `::1`, which is the IPv6 loopback address of the local Kali system.
- SSH connection-penalty events triggered by repeated invalid-user activity.
- Dropped SSH connections as a result of the penalty mechanism.

No successful authentication, privilege escalation, data access, or system compromise was observed.

This was a controlled security testing exercise performed within a laboratory environment.

---

## 2. Objective

The objective of this exercise was to demonstrate an end-to-end SOC monitoring workflow:

1. Generate controlled security events.
2. Collect Linux authentication logs.
3. Ingest the logs into Splunk.
4. Search and analyze the events.
5. Identify suspicious authentication activity.
6. Investigate the source and timeline.
7. Observe the system's defensive response.
8. Document the investigation.

---

## 3. Detection

The initial Splunk search used to identify invalid-user authentication activity was:

 The search returned 16 events containing the Invalid user message.

The events were associated with:

Host: kali
Log source: /var/log/auth.log
Sourcetype: linux_secure

This confirmed that Splunk was successfully collecting and searching the Linux authentication events generated during the controlled test.


## 4. Investigation:

To identify the attempted username and source address, the following SPL query was used:

index=* "Invalid user" earliest=-1h
| rex "Invalid user (?<target_user>\S+) from (?<src_ip>\S+)"
| search target_user=*
| stats count earliest(_time) as first_seen latest(_time) as last_seen by target_user src_ip
| convert ctime(first_seen) ctime(last_seen)

The investigation returned:

Field	Result
Target User	fakeuser
Source IP	::1
Matching Events	4
First Seen	09/24/2026 12:51:07
Last Seen	09/24/2026 12:53:13


The attempted username fakeuser did not correspond to a legitimate account on the system.

The source address ::1 is the IPv6 loopback address, meaning the activity originated from the local Kali system rather than an external network host.


## 5. Authentication Activity

The underlying SSH logs contained messages such as:

Invalid user fakeuser from ::1

These events demonstrated repeated attempts to authenticate using a nonexistent username.

Because the test was intentionally generated from the local Kali system, the activity was classified as a controlled authentication simulation rather than an external attack.


## 6. SSH Defensive Response

Repeated invalid-user authentication activity caused the SSH service to apply a connection penalty.

The following search was used to identify penalty events:

index=* "penalty" earliest=-1h
| stats count by host

The search returned:

Host: kali
Penalty events: 8

Additional connection drops were identified using:

index=* "drop connection" earliest=-1h
| stats count by host

The search returned:

Host: kali
Dropped-connection events: 7

The penalty and dropped-connection events represent different event categories and were not added together.

The SSH service also reported an IPv6 penalty of approximately 15.600 seconds during the controlled test.


## 7. Timeline
12:51:07 PM

The first identified event showed:

Invalid user fakeuser from ::1

*12:53:13 PM

Additional invalid-user authentication activity was recorded.

During the test

The SSH service activated an IPv6 connection penalty of approximately 15.600 seconds.

Following the penalty

Multiple SSH connection attempts were dropped by the SSH service.

The activity was monitored through Splunk using the authentication logs collected from /var/log/auth.log.


## 8. Analysis

The investigation showed repeated SSH authentication attempts targeting a nonexistent account.

The key findings were:

The attempted username was fakeuser.
The source address was ::1.
::1 represents the local IPv6 loopback interface.
The activity therefore originated from the local Kali laboratory system.
SSH detected the repeated invalid-user activity.
SSH applied a connection penalty.
Several subsequent connections were dropped.
No successful authentication was identified.

The evidence does not indicate an external attacker because the source was the local loopback address.


## 9. Impact Assessment

No security compromise was identified during the exercise.

The investigation found no evidence of:

Successful authentication.
Account compromise.
Privilege escalation.
Unauthorized command execution.
Data access.
Data exfiltration.
Malware execution.
System compromise.

The exercise had no production impact because it was conducted in a controlled laboratory environment.


## 10. Classification
Category	Classification
Event Type	Controlled SSH authentication / invalid-user activity
Environment	Security laboratory
Severity	Informational / Low
Source	Local IPv6 loopback ::1
Target Account	fakeuser
Status	Closed


## 11. Defensive Recommendations

For a real production environment, a SOC analyst investigating similar activity should:

Identify the source IP address of authentication attempts.
Determine whether the source is internal or external.
Review authentication activity before and after the detected events.
Check for successful authentication following failed attempts.
Investigate targeted usernames and accounts.
Review privilege escalation activity.
Review suspicious commands and processes.
Restrict unnecessary SSH exposure.
Consider key-based authentication where appropriate.
Configure SIEM alerts for repeated authentication failures and suspicious login patterns.


## 12. Evidence Collected

The following evidence was produced during the investigation:

Splunk SOC security monitoring dashboard.
Splunk invalid-user authentication search results.
Extracted username and source IP information.
Authentication event timeline.
SSH connection-penalty events.
Dropped SSH connection events.
Linux authentication logs from /var/log/auth.log.


## 13. Skills Demonstrated

This project demonstrated practical experience with:

Linux security monitoring.
Splunk Enterprise.
SIEM log ingestion.
Linux authentication logs.
SSH monitoring.
Splunk Search Processing Language (SPL).
Event filtering.
Regular-expression field extraction using rex.
Authentication-event investigation.
Timeline analysis.
Security alert analysis.
Incident documentation.
SOC investigation methodology.


## 14. Conclusion

This controlled laboratory exercise demonstrated an end-to-end security monitoring workflow:

Generate → Detect → Collect → Search → Analyze → Investigate → Document

Splunk successfully collected and provided visibility into Linux SSH authentication events.

The investigation identified repeated invalid-user authentication attempts against the nonexistent fakeuser account. The activity originated from the local IPv6 loopback address ::1, confirming that the events were generated locally as part of the controlled security test.

The SSH service responded by applying a connection penalty and dropping subsequent connections.

No successful authentication, privilege escalation, unauthorized access, or system compromise was observed.

Final Status: Closed — Controlled Lab Simulation


