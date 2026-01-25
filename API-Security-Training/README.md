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
	5..	Which endpoint groups look security-critical at first glance?
	6..	Which HTTP methods are mainly used in the Identity area?
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



## API Hacking

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

















## Automated API Testing 

### API Linting using Spectral


### SAST Scan using Semgrep

findet schwachstellen und fehlkonfiguration
semantische Codeanalyse, die Schwachstellen findet und
statisch vor allem API7,
https://semgrep.dev/
Codestandards durchsetzen kann

```shell
cd API-Security-Training/crAPI/codebase/
semgrep --config=auto
```

### DAST Scan using Cats

```shell
cats \
  --server=http://localhost:8888 \
  --contract=openapi-spec/crapi-openapi-spec.json \
  -H "Authorization=Bearer <ACCESS_TOKEN>"
```



