# LAB: API Security

## Sunset Calculator API

To optimize automation in our smart home, we want to adjust it to sunrise and sunset times. We want to calculate these times via API.

1. Select your location and its zip code for which you want to determine the times of sunrise and sunset
2. Open the browser of your choice 
3. Call the API to calculate the latitude and longitude by copying and adjusting the URL to match your country and postalcode
4. Check the response and search for “latitude” and “longitude”
5. Call the API to determine the times of sunrise and sunset by copying and adjusting the URL with your latitude and longitude
6. Check the response and search for “sunrise” and “sunset”

There are 2 APIs that we can make use of to solve our problem:

Calculate latitude and longitude for a given country and postalcode, e.g.:
http://api.zippopotam.us/de/70469

Determine the times of sunrise and sunset for latitude and longitude, e.g.:
https://api.sunrise-sunset.org/json?lat=48.8098&lng=9.1612


## Identify HTTP Operations

Match the statements with the correct HTTP operation (GET, POST, PUT, DELETE):

* searchManual
* createReplacementRequest
* updateContactDeatils
* fetchBlackweekdeals
* retrieveProduct
* makePayment
* searchSpareparts
* createAccount
* placeOrder
* deleteProduct


## API Specification

1. Open folder Swagger:
  ```bash
  cd API-Security-Training/Swagger/
  ```
2. Run docker compose:
  ```bash
    docker compose up
  ```
3. Visit `http://localhost:8081` to see the Swagger UI of the crAPI

Explore the Swagger UI of the OWASP crAPI. Focus especially on the Identity / Auth endpoints.
   
Answer the following questions by only reading the OpenAPI specification (do not execute any requests yet).
1. Getting Started
    1.	What is the base URL of the API?
    2.	Which authentication methods are supported?
    3.	Which response codes are used in the specification?
    4. How is the API structured (endpoint groups / tags)?
	5.	Which endpoint groups look security-critical at first glance?
	6.	Which HTTP methods are mainly used in the Identity area?
2. Identity & Authentication
	1.	Which endpoints are used for user registration?
	2.	Which endpoint is used for user login?
	3.	What data is required in the request body for the login endpoint?
	4.	Which endpoints are obviously callable without authentication?
3. Versioning & Complexity
	1.	Do you see multiple versions of similar authentication endpoints?
	2.	Why could multiple versions increase the security risk?
	3.	Which version would you attack first as an attacker – and why?
4. Security Observations
	1.	Which information does Swagger already reveal to a potential attacker?
	2.	Which Security risks could already be relevant, just by looking at the specification?







---



## APIs Security Challenges

This lab is designed to simulate real-world API vulnerabilities (OWASP API Top 10) and let you explore them using your own skills and tools.

**Tools Required:**
- Firefox Browser with FoxyProxy extension
- Burp Suite 
- crAPI (running locally)

**Setup crAPI:**

1. Start crAPI using Docker:
    ```shell
    cd API-Security-Training/crAPI/
    docker compose -f docker-compose.yml --compatibility up -d
    ```
2. Wait for all services to start.
3. Start Burp Suite.
4. Start Firefox and set FoxyProxy to route traffic through Burp Suite.
5. Visit `http://localhost:8888` to access the frontend.
6. Note: All emails are sent to mailhog service by default and can be checked on `http://localhost:8025`


### Challenges Overview

You are free to attempt the challenges in any order. Some challenges depend on others, so read carefully.


#### Challenge 1 – Broken Object-Level Authorization (BOLA)
> Gain access to another user’s vehicle location via the API.

#### Challenge 2 – Mechanic Report Disclosure
> View the mechanic service report of a different user by manipulating request IDs.

#### Challenge 3 – Broken User Authentication
> Reset the password of another user.

#### Challenge 4 – Sensitive Data Exposure via Order API
> Find an API endpoint that reveals personal data of other users.

#### Challenge 5 – Internal Video Properties Leak
> Identify internal metadata or implementation details exposed via video upload API.

#### Challenge 6 – Rate Limiting DoS
> Perform a denial of service using the “Contact Mechanic” feature.

#### Challenge 7 – Broken Function-Level Authorization (BFLA)
> Delete a video uploaded by another user using an unauthorized API endpoint.

#### Challenge 8 – Mass Assignment: Free Item Exploit
> Manipulate order status to receive refunds or items without paying.

#### Challenge 9 – Increase Balance by $1,000+
> Combine several techniques to increase your user balance.

#### Challenge 10 – Internal Parameter Abuse
> Modify video conversion settings via undocumented parameters.

#### Challenge 11 – SSRF
> Make the server send an HTTP request to an external website.

#### Challenge 12 – NoSQL Injection
> Exploit NoSQL injection to get coupon codes without knowing the actual values.

#### Challenge 13 – SQL Injection
> Use SQL injection to reuse or reclaim a previously used coupon.

#### Challenge 14 – Unauthenticated Access
> Find a sensitive API endpoint that works without authentication.

#### Challenge 15 – JWT Forgery
> Manipulate a JWT to impersonate another user without needing their password.

### Good luck!

Please document your findings and be ready to share your techniques and lessons learned.







---

## Tool-Based API Security Testing

After some manual testing, you will now use several automated tools to test and evaluate the security of the crAPI application. These tools support different layers of security testing including API specification linting, static code analysis, dynamic scanning, and third-party dependency vulnerability scanning.

Each tool provides a unique perspective and complements manual testing efforts.


### 1️. API Linting using Vacuum

Vacuum is a tool for linting OpenAPI specifications to find inconsistencies, missing security requirements, and bad practices.

This helps you catch problems early in the API design phase before the API is even implemented.

```shell
cd API-Security-Training/crAPI/Swagger/
vacuum lint crapi-openapi-spec.json
```

**Questions:**
- What types of vulnerabilities or issues did vacuum tool detect?
- What could happen if a API spec is publicly accessible?
- Were any security-related fields (e.g., authentication, HTTPS-only) missing?
- How could these issues impact the API in production?


### 2. Static Applicatio Security Testing (SAST) using Semgrep

Semgrep is a code analyzer that detects:
- Common vulnerabilities and misconfigurations
- Violations of secure coding standards

```shell
cd API-Security-Training/crAPI/codebase/
semgrep --config=auto
```

**Questions:**
- What types of vulnerabilities or issues did semgrep detect?
- What’s the difference between a linter and a SAST tool like Semgrep?
- How many vulnerabilities were detected by Semgrep?
- Pick out three findings and take a closer look at them. What kind of vulnerabilities are they?
- Which findings would you fix first, and why?

### 3. Dynamic API Testing (DAST) using CATS

CATS is a dynamic testing tool that scans your running API based on an OpenAPI specification. It tests real endpoints and performs fuzzing, injection, and behavior checks.

1. Log in to crAPI using the browser
2. Open Burp Suite and copy the Bearer token from the login request
3. Run CATS using the token and OpenAPI spec:

```shell
cd API-Security-Training/crAPI/Swagger/
cats \
--server=http://localhost:8888 \
--contract=crapi-openapi-spec.json \
-H "Authorization=Bearer <ACCESS_TOKEN>"
```

**Questions:**
- What types of vulnerabilities or issues did cats detect?
- How many findings did CATS report?
- Did CATS discover any vulnerabilities missed during manual testing?
- Were any of the results false positives?
- What are the limits of automated DAST tools?



### 4. 3rd Party Vulnerability Scanning using Trivy

Trivy scans Docker images and file systems for vulnerable dependencies (CVEs) and outdated packages.

This is important for identifying supply chain risks in your application.

1. Check available images:
    ```bash
    docker images
    ```
2. Choose three images from the list and scan them:
    ```bash
    trivy image <image:tag>
    ```

**Questions:**
- What types of vulnerabilities or issues did trivy detect?
- Which image had the highest number of vulnerabilities?
- Should all vulnerabilities be fixed immediately?
- Were any of them rated HIGH or CRITICAL?
- What would be your recommended mitigation steps?

### 5. Reflection
After completing the tool-based security testing, reflect on the overall findings:

- How did each tool contribute to the security evaluation?
- What are the advantages of tools over manual testing?
- What are some things that are difficult to test using tools?
- Which tools were mostly noise?
- How could you integrate these tools into your DevOps environment?



## Cleanup

Stop all containers:

```shell
cd API-Security-Training/crAPI/
docker compose down
```
