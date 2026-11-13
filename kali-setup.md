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
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable docker --now
sudo usermod -aG docker $USER
```

> Use the **Docker Compose v2 plugin** (`docker compose ...`), not the old
> `docker-compose` (v1) package – the Pizza Pronto lab relies on v2 features.
> After `usermod`, log out and back in so your user is in the `docker` group.

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


### Install semgrep
```bash
sudo apt install -y pipx
pipx ensurepath && source ~/.profile
pipx install semgrep
```

### Install Cats
1. Download binary: https://github.com/Endava/cats/releases
2. Copy to /usr/local/bin:
    ```bash
    sudo cp cats /usr/local/bin/cats
    ```

### Install vacuum
```bash
sudo su
curl -fsSL https://quobix.com/scripts/install_vacuum.sh | sh
exit
```

### Install trivy

```bash
sudo apt install trivy
``` 

## Pizza Pronto lab (Supply Chain, DevSecOps, Skill Battle)

This lab runs everything locally in Docker – no accounts, no cloud. It needs the Docker
setup above (`docker.io`, `docker-compose`, user in the `docker` group).

**VM requirements:** at least **8 GB RAM** and about **10 GB free disk** for the images.

Prepare it once (with internet). Afterwards it runs fully offline:

```bash
cd Introduction-to-IT-Security/labs/pizza-pronto
./lab.sh setup
```

`./lab.sh setup` pulls all images (Gitea, act_runner, Verdaccio, Renovate, Node) and
builds the shop + the `secscan` scanner image (~3 GB, contains gitleaks, semgrep, trivy
with its vulnerability DB, syft, hadolint, guarddog). For the OVA, run `setup` once so
every image and the npm package cache are baked in.

Verify the images are present:

```bash
docker image ls | grep -E 'pizza-pronto|gitea|verdaccio|renovate|node'
```

Start the lab with `./lab.sh start` (Supply Chain) or `./lab.sh devsecops` (adds Gitea + CI).
See `Introduction-to-IT-Security/labs/pizza-pronto/README.md`.
