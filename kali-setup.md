# Setup of the Kali Linux Environment

## Default User
Username: kali
Password: kali

## Initial Setup

### Update and Upgrade
To ensure your Kali Linux environment is up to date, run the following commands:

```bash
sudo apt update && sudo apt -y upgrade
```

### Install Docker
To install Docker, execute the following commands:

```bash
sudo apt install -y docker.io
sudo apt install docker-compose
sudo systemctl enable docker --now
sudo usermod -aG docker $USER
```

### Install Burp JWT Extension

1. Open Burp Suite.
2. Go to the "Extender" tab.
3. Click on "BApp Store".
4. Search for "JWT" and install the "JWT" extension.
5. Restart Burp Suite to activate the extension.

### Install FoxyProxy & Burp Cewrtificate
FoxyProxy is a browser extension that simplifies managing multiple proxy configurations. It is particularly useful when working with Burp Suite.
1. Install FoxyProxy in your browser (available for Firefox and Chrome).
2. Configure FoxyProxy to route traffic through Burp Suite (default is localhost:8080).
3. Burp certificate installation:
   - In Burp Suite, go to the "Proxy" tab and then the "Options" sub-tab.
   - Click on "Import / export CA certificate" and choose "Export to file".
   - Save the certificate (e.g., `burp_cert.cer`).
   - Import this certificate into your browser's trusted root certification authorities.


### Download all docker compose files from the repository

* Clone this repo
* Navigate to the docker directories
* `docker compose pull`


## Install Cats
To install Cats (a security testing tool for APIs), run the following commands:




todo
vacuum / liniting tool
cats
sonarqube