# LAB: Introduction to IT Security

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