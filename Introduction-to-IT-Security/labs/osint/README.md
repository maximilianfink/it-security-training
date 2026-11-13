# OSINT Challenge: Investigate Pizza Pronto (45 min)

> Attackers do their homework before they phish. In this challenge **you** are the attacker:
> find out as much as possible about [Pizza Pronto](../../company/README.md) – only from "public" material.
> At the end you use your findings to build a convincing pretext for the next lab (spear phishing).

**Rules**
- Work in your team. Write every answer – and **how** you found it – into the [Lab Report](../../lab-report.md) (section "OSINT Challenge").
- Everything here is fictional and lives on your VM. **Never** use these techniques against real people
  or companies without permission.
- Each question gives points (in brackets). Stuck? Open the hints one by one – but try first!

| Part | Topic | Time | Points |
|---|---|---|---|
| A | Photos | 10 min | 6 |
| B | Documents | 10 min | 6 |
| C | Website | 15 min | 11 (+2 bonus) |
| D | Build the pretext | 10 min | – |

## Setup (2 min)

The Pizza Pronto website is the **same shop** you will attack and defend later in the
[Supply Chain & DevSecOps lab](../pizza-pronto/README.md) – today you only do reconnaissance.

In your Kali VM, open a terminal and start the lab. If `./lab.sh setup` was never run on your VM – or your VM was prepared before this OSINT challenge existed (no *Team* page on the website) – run `./lab.sh setup` once first (needs internet):

```bash
cd Introduction-to-IT-Security/labs/pizza-pronto
./lab.sh start                                                # starts the shop – it keeps running for the later labs
sudo apt install -y libimage-exiftool-perl gobuster whatweb   # usually already installed
```

The website runs at **http://localhost:3000**. Leave the login pages (`/kitchen`, `/admin`) alone for now – they are part of the later lab.

Then go to the OSINT files:

```bash
cd ../osint/files
ls -l
```

### Start here: your first exiftool command

`exiftool` shows the metadata that is stored *inside* a file – things you don't see when you open it:

```bash
exiftool lena-first-day.jpg
```

You get a long list (`Make`, `Camera Model Name`, `Date/Time Original`, `GPS Position`, …).
Tip: `exiftool -s lena-first-day.jpg | grep -i gps` shows only the GPS lines.

---

## Part A – Photos (10 min)

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

## Part B – Documents (10 min)

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

## Part C – Website (15 min)

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

## Part D – Build the pretext (10 min)

You now know a lot about Pizza Pronto. Use **at least three facts** from parts A–C and write one of these:

- **Phone script (vishing):** you call Lena as "Herr Brandt" from Mühle Schäfer, or
- **Spear-phishing e-mail** to Lena.

In the lab report, note:
1. Which facts make your story convincing?
2. Which **red flags** could Lena still notice?
3. What should Lena do to verify the call or e-mail?

Then continue with the [Social Engineering lab](../../README.md#social-engineering-attack-simulation-20-min) (variant "Pizza Pronto").

---

## Debrief – how could Pizza Pronto have prevented this?

Prepare one countermeasure per finding; we discuss them together. Think about:
- metadata in photos and documents
- robots.txt (is it a security feature?)
- backups and notes in the webroot
- comments in the HTML source
- personal details on the team page

## Afterwards: self-check (5 min, only your own data!)

- Search for your own name (+ city) and do an image search with your profile photo.
- Check your e-mail address on [Have I Been Pwned](https://haveibeenpwned.com).
- Phone: Is location saved in your camera photos? Are your social media profiles public?
