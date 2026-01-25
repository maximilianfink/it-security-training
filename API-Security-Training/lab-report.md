# LAB Report – API Security Training

**Name:**  
**Date:**  

---

## 1. Sunset Calculator API

**ZIP Code used:**  
**Country:**  

### Step 1 – Coordinates
- API URL used:  
- Latitude:  
- Longitude:  

### Step 2 – Sunrise & Sunset
- API URL used:  
- Sunrise:  
- Sunset:  

---

## 2. Identify HTTP Operations

Match each action to its HTTP method:

| Action                   | HTTP Method |
|--------------------------|-------------|
| searchManual             |             |
| createReplacementRequest |             |
| updateContactDetails     |             |
| fetchBlackweekdeals      |             |
| retrieveProduct          |             |
| makePayment              |             |
| searchSpareparts         |             |
| createAccount            |             |
| placeOrder               |             |
| deleteProduct            |             |

---

## 3. Swagger Analysis

1. Getting Started
    1.	What is the base URL of the API?
    2.	Which authentication methods are supported?
    3.	Which response codes are used in the specification?
	5.	Which endpoint groups look security-critical at first glance?
2. Identity & Authentication
	1.	Which endpoints are used for user registration?
	2.	Which endpoint is used for user login?
	3.	What data is required in the request body for the login endpoint?
	4.	Which endpoints are obviously callable without authentication?
3. Versioning & Complexity
	1.	Do you see multiple versions of similar authentication endpoints?
	2.	Why could multiple versions increase the security risk?
	3.	Which version would you attack first as an attacker and why?
4. Security Observations
	1.	Which information does Swagger already reveal to a potential attacker?
	2.	Which Security risks could already be relevant, just by looking at the specification?

---

## 4. crAPI Hacking Challenges

Complete the challenges below. Document your approach and results.

| Challenge                             | Solved? | Notes / What you tried |
|--------------------------------------|---------|--------------------------|
| 1. BOLA                               | ☐       |                          |
| 2. Mechanic Report Disclosure         | ☐       |                          |
| 3. Broken User Authentication         | ☐       |                          |
| 4. Sensitive Data Exposure            | ☐       |                          |
| 5. Internal Video Metadata Leak       | ☐       |                          |
| 6. Rate Limiting DoS                  | ☐       |                          |
| 7. BFLA                               | ☐       |                          |
| 8. Mass Assignment Exploit            | ☐       |                          |
| 9. Increase Balance                   | ☐       |                          |
| 10. Internal Parameter Abuse          | ☐       |                          |
| 11. SSRF                              | ☐       |                          |
| 12. NoSQL Injection                   | ☐       |                          |
| 13. SQL Injection                     | ☐       |                          |
| 14. Unauthenticated Access            | ☐       |                          |
| 15. JWT Forgery                       | ☐       |                          |

---

## 5. Tool-Based API Testing

### 5.1 API Linting using Vacuum

- What types of vulnerabilities or issues did vacuum tool detect?
- What could happen if a API spec is publicly accessible?
- Were any security-related fields (e.g., authentication, HTTPS-only) missing?
- How could these issues impact the API in production?


### 5.2 Static Applicatio Security Testing (SAST) using Semgrep

- What types of vulnerabilities or issues did semgrep detect?
- What’s the difference between a linter and a SAST tool like Semgrep?
- How many vulnerabilities were detected by Semgrep?
- Pick out three findings and take a closer look at them. What kind of vulnerabilities are they?
- Which findings would you fix first, and why?

### 5.3 Dynamic API Testing (DAST) using CATS

- What types of vulnerabilities or issues did cats detect?
- How many findings did CATS report?
- Did CATS discover any vulnerabilities missed during manual testing?
- Were any of the results false positives?
- What are the limits of automated DAST tools?

### 5.4 3rd Party Vulnerability Scanning using Trivy

- What types of vulnerabilities or issues did trivy detect?
- Which image had the highest number of vulnerabilities?
- Should all vulnerabilities be fixed immediately?
- Were any of them rated HIGH or CRITICAL?
- What would be your recommended mitigation steps?

### 5.5 Reflection

- How did each tool contribute to the security evaluation?
- What are the advantages of tools over manual testing?
- What are some things that are difficult to test using tools?
- Which tools were mostly noise?
- How could you integrate these tools into your DevOps environment?