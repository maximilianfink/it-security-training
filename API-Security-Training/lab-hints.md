# crAPI Hacking Challenges – Hints

Each challenge has two hints. Check them **only if you're stuck**.  

---

## Challenge 1 – BOLA: Vehicle Location Access
**Hint 1:** Observe how vehicle information is requested in the frontend.  
**Hint 2:** Think about how the backend decides *which* object belongs to *which* user.

---

## Challenge 2 – Mechanic Report Disclosure
**Hint 1:** Trigger a mechanic-related action and inspect the resulting request.  
**Hint 2:** Ask yourself how the API links reports to users.

---

## Challenge 3 – Broken User Authentication
**Hint 1:** Look closely at the password recovery workflow.  
**Hint 2:** Consider where temporary authentication data might be delivered.

---

## Challenge 4 – Sensitive Data Exposure
**Hint 1:** Inspect responses from order-related endpoints.  
**Hint 2:** Think about what information an API *should not* return by default.

---

## Challenge 5 – Internal Video Metadata Leak
**Hint 1:** Upload or modify a video and inspect the full API response.  
**Hint 2:** Look for fields that seem more relevant to developers than users.

---

## Challenge 6 – Rate Limiting DoS
**Hint 1:** Identify an endpoint that triggers backend processing.  
**Hint 2:** Think about what happens if the same action is requested repeatedly.

---

## Challenge 7 – Delete Video of Another User (BFLA)
**Hint 1:** Explore which HTTP methods are supported for video-related endpoints.  
**Hint 2:** Consider how the API checks whether you are allowed to perform an action.

---

## Challenge 8 – Mass Assignment Refund
**Hint 1:** Inspect requests that update or change order data.  
**Hint 2:** Think about what happens if the API trusts all client-supplied fields.

---

## Challenge 9 – Increase Balance by $1000+
**Hint 1:** Review how prices and quantities are handled in orders.  
**Hint 2:** Consider how refunds or balance changes are calculated.

---

## Challenge 10 – Modify Video Properties
**Hint 1:** Look at requests that update existing video objects.  
**Hint 2:** Think about whether the backend validates *all* supplied attributes.

---

## Challenge 11 – SSRF
**Hint 1:** Identify features where the backend connects to other services.  
**Hint 2:** Ask yourself who controls the destination of those connections.

---

## Challenge 12 – NoSQL Injection
**Hint 1:** Examine how user input is used in database queries.  
**Hint 2:** Think about how query logic could be influenced, not just values.

---

## Challenge 13 – SQL Injection
**Hint 1:** Look for inputs that interact with stored data like coupons or codes.  
**Hint 2:** Consider how the backend builds database queries.

---

## Challenge 14 – Unauthenticated Endpoint
**Hint 1:** Observe which requests work while you are logged in.  
**Hint 2:** Question whether authentication is *always* enforced server-side.

---

## Challenge 15 – JWT Forgery
**Hint 1:** Inspect the structure of the authentication token.  
**Hint 2:** Think about which parts of the token the server actually verifies.