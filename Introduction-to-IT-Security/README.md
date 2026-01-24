# LAB: Introduction to IT Security

## Detecting Phishing Emails (10 min)

Use the following quiz to practice identifying phishing emails:
https://phishingquiz.withgoogle.com/


---


## Social Engineering Attack Simulation (20 min)

In this lab, you will simulate a social engineering attack using a phishing website to demonstrate how attackers can trick users into revealing sensitive information.

We want to fake the login page of a well-known service (e.g., Bosch Corporate Benefits) and create a spear phishing email to lure users into entering their credentials.

### 1. Choose a Phishing Domain

Think of a domain name that closely resembles the legitimate service's domain. Te legitimate site is "bosch.mitarbeiterangebote.de".
You can check free domains on websites like https://www.checkdomain.de.

### 2. Prepare the Phishing Site

We will use the Social-Engineer Toolkit (SET) to create a phishing site that mimics a legitimate login page.

1. Start the Social-Engineer Toolkit:
   ```bash
   sudo setoolkit
   ```
2. Selet Website Attack Vectors (1)
3. Select Credential Harvester Attack Method (3)
4. Select Site Cloner (2)
5. Enter the URL of the legitimate site to clone:
   ```
   https://bosch.mitarbeiterangebote.de/login
   ```
6. Open your web browser and navigate to "http://localhost" to see the cloned site.
7. Enter (fake) credentials and submit the form. Observe the behavior.
8. Go back to the terminal where SET is running to view the captured credentials.

### 3. Formulate a Spear Phishing Email

Create a convincing email (DE or EN) that appears to come from a trusted source within the organization. Include a link to the cloned site.

The usage of AI tools is allowed to draft the email content.


---

## Active Scanning (20 min)

In this lab, you will use scanning tools to identify vulnerabilities in a target system.

### 1. Set Up the Target System

```bash
dvwa-start
```
This will start a vulnerable web application on your local machine at `http://localhost:42001`.

### 2. Use nmap to Scan for Open Ports and Services

Run the following command to scan the target system:
```bash
nmap -sV localhost -p 42001
```
Which services are running on the open ports?

### 3. Research Known Vulnerabilities

Use the service information obtained from nmap to search for known vulnerabilities in public databases such as the [CVE database](https://cve.mitre.org/) or [NVD](https://nvd.nist.gov/).

List any interesting vulnerabilities you found.

### 4. Use Nikto to Scan for Web Vulnerabilities

Run Nikto against the target web application:
```bash
nikto -C all -h http://localhost:4280
```

What interesting information did you find about the web application?


### 5. Stop the Target System

```bash
dvwa-stop
```


---

## Vulnerability Scanning (30 min)

idee:
ziel aufspüren, nmap scan, verwundbarkeiten finden, exploitieren mit metasploit

nach https://medium.com/@mrarslan5156/a-practice-guide-to-exploring-ftp-vulnerabilities-in-metasploitable-2-using-debian-linux-d96f7e7e82fa

1. Start the VM 
2. Find the IP address of the target VM
   1. Use `ip a` command in the target VM terminal to find the local network IP range (eth1, e.g. 192.168.56.102/24).
   2. Use `nmap -sn <network-range>` from your Kali VM to find the target VM IP. There will be two devices found called "Oracle VirtualBox virtual NIC", you and the target VM.
3. Scan the target using nmap: `nmap -sV -p- 192.168.0.237`
4. focus on ftp service. search for public known vulnerabilities of the ftp service and version
5. start metasploit `msfconsole`
todo

---

## CVSS Calculation (10 min)

In this lab, you will calculate the CVSS score for a given vulnerability scenario.

### Scenario

During an internal security assessment, a vulnerability was discovered in a custom-built HR web portal running on a Linux server.

The vulnerable functionality is part of a document upload feature that is only accessible to members of the HR department.
Access to the HR portal requires:
- A corporate user account
- Membership in the HR role
- VPN access

The HR portal is generally well protected and not accessible to regular employees or external users.

Due to insufficient server-side validation, an attacker with access to the HR portal can upload a specially crafted PHP file, which under certain conditions gets executed by the web server. Successful exploitation results in remote code execution with root privileges.

Exploitation:
- Requires deep technical knowledge of the application logic
- Requires precise timing and a specific server configuration
- Is not reliably exploitable and may fail multiple times

No user interaction is required beyond the attacker’s own actions.

After exploitation, the attacker can:
- Access and modify sensitive HR documents
- Modify system configuration and scripts

The system remains partially operational, but service stability is degraded.

The compromise does not automatically propagate to other systems.

### Task

Calculate the CVSS v3.1 base score using an online calculator (e.g., https://www.first.org/cvss/calculator/3.1)
