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

