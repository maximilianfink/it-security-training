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



## Hacking crAPI

### Setup crAPI
Via docker compose

```shell
cd API-Security-Training/crAPI/
docker compose pull
docker compose -f docker-compose.yml --compatibility up -d
```

Burpsuite starten
Firefox öffnen und FoxyProxy auf burp setzen

## Sign up a new User

* Visit `http://localhost:8888`
  * Note: All emails are sent to mailhog service by default and can be checked on
`http://localhost:8025`
* Click on Sign Up
* Fill the form with a new user


## BOLA Vulnerabilities

### Challenge 1 - Access details of another user’s vehicle

To solve the challenge, you need to leak sensitive information of another user’s vehicle.

* Since vehicle IDs are not sequential numbers, but GUIDs, you need to find a way to expose the vehicle ID of another user.

* Find an API endpoint that receives a vehicle ID and returns information about it.

### Challenge 2 - Access mechanic reports of other users

crAPI allows vehicle owners to contact their mechanics by submitting a "contact mechanic" form. This challenge is about accessing mechanic reports that were submitted by other users.

* Analyze the report submission process

* Find an hidden API endpoint that exposes details of a mechanic report

* Change the report ID to access other reports

## Broken User Authentication

### Challenge 3 - Reset the password of a different user

* Find an email address of another user on crAPI

* Brute forcing might be the answer. If you face any protection mechanisms, remember to leverage the predictable nature of REST APIs to find more similar API endpoints.

## Excessive Data Exposure

### Challenge 4 - Find an API endpoint that leaks sensitive information of other users

### Challenge 5 - Find an API endpoint that leaks an internal property of a video

In this challenge, you need to find an internal property of the video resource that shouldn’t be exposed to the user. This property name and value can help you to exploit other vulnerabilities.

## Rate Limiting

### Challenge 6 - Perform a layer 7 DoS using ‘contact mechanic’ feature

## BFLA 

### Challenge 7 - Delete a video of another user

* Leverage the predictable nature of REST APIs to find an admin endpoint to delete videos

* Delete a video of someone else

## Mass Assignment

### Challenge 8 - Get an item for free

crAPI allows users to return items they have ordered. You simply click the "return order" button, receive a QR code and show it in a USPS store.
To solve this challenge, you need to find a way to get refunded for an item that you haven’t actually returned.

* Leverage the predictable nature of REST APIs to find a shadow API endpoint that allows you to edit properties of a specific order.

### Challenge 9 - Increase your balance by $1,000 or more

After solving the "Get an item for free" challenge, be creative and find a way to get refunded for an item you never returned, but this time try to get a bigger refund.

### Challenge 10 - Update internal video properties

After solving the "Find an API endpoint that leaks an internal property of videos" challenge, try to find an endpoint that would allow you to change the internal property of the video. Changing the value can help you to exploit another vulnerability.

## SSRF

### Challenge 11 - Make crAPI send an HTTP call to "[www.google.com](www.google.com)" and return the HTTP response. 

## NoSQL Injection

### Challenge 12 - Find a way to get free coupons without knowing the coupon code.

## SQL Injection

### Challenge 13 - Find a way to redeem a coupon that you have already claimed by modifying the database

## Unauthenticated Access

### Challenge 14 - Find an endpoint that does not perform authentication checks for a user.

## JWT Vulnerabilities

### Challenge 15 - Find a way to forge valid JWT Tokens

JWT Authentication in crAPI is vulnerable to various attacks. Find any one way to forge a valid JWT token and get full access to the platform.








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
