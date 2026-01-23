# LAB: API Security

## 1. Sunset Calculator API

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


## 2. Identify HTTP Operations

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


## 3. crAPI API Specification

- open folder "Lab/02 Swagger Environment"
- start docker environment: `docker compose up -d`
- visit `http://localhost:8081` to see the Swagger UI of the crAPI


Explore the Swagger UI of the OWASP crAPI.

Focus especially on the Identity / Auth endpoints.

Answer the following questions by only reading the OpenAPI specification
(do not execute any requests yet).

1. API Overview
	1.	How is the API structured (endpoint groups / tags)?
	2.	Which endpoint groups look security-critical at first glance?
	3.	Which HTTP methods are mainly used in the Identity area?

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



## Install Tools

via VM

### Docker

### Bruno

### Burp Suite Community Editon

### Cats

## Start crAPI

```shell
cd crAPI/docker
docker compose pull
docker compose -f docker-compose.yml --compatibility up -d
```

## Analyse OpenAPI Spec 

Visit `http://localhost:8081` 

•	Welche Endpoints gibt es?
	•	Welche HTTP-Methoden?
	•	Welche IDs werden verwendet?
	•	Wie funktioniert Authentication?
	•	Gibt es Versionierung?
	•	Welche Endpoints sind ungeschützt?

👉 Wichtig: Noch nichts ausführen, nur lesen!


## Build a Bruno Collection

* Open Bruno 
* Create a new collection based on the OpenAPI Spec (see Lab/crAPI/openapi-spec/crapi-openapi-spec.json)
* Collection > Vars > Pre request > add a variable `baseUrl` with value `http://localhost:8888`

## Sign up a new User

* Visit `http://localhost:8888`
  * Note: All emails are sent to mailhog service by default and can be checked on
`http://localhost:8025`
* Click on Sign Up
* Fill the form with a new user


## Cats Scan

```shell
cats \
  --server=http://localhost:8888 \
  --contract=openapi-spec/crapi-openapi-spec.json \
  -H "Authorization=Bearer <ACCESS_TOKEN>"
```




Asdfg1234!