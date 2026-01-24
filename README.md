# IT Security Training Setup

## Initial Lab Setup

All labs are prepared in a Kali Linux virtual machine (VM). We will use VirtualBox to run the VM on your local machine.

### Step 1: Install VirtualBox

1. Download and install the latest version of "Visual C++ Redistributable" (needed for Virtualbox): https://aka.ms/vc14/vc_redist.x64.exe
2. Download and install VirtualBox: https://download.virtualbox.org/virtualbox/7.2.4/VirtualBox-7.2.4-170995-Win.exe

### Step 2: Download the Virtual Machines

The .ova files for the virtual machines will be provided on the fileshare. Copy the files to your local machine:
* metasploitable.ova
* it-security-training.ova

### Step 3: Import the Kali Linux VM into VirtualBox

1. Open VirtualBox.
2. Go to "File" > "Import Appliance".
3. Select the downloaded VM files and follow the prompts to import it.
4. Once imported, you should see two virtual machines in your VirtualBox Manager.
5. Configure the network settings of the it-security-training VM:
   - Right-click on the Kali Linux VM and select "Settings".
   - Go to the "Network" tab.
   - Ensure that "Adapter 1" is enabled and set to "NAT".
   - Ensure that "Adapter 2" is enabled and set to "Host-only Adapter".
6. Configure the network settings of the metasploitable VM:
   - Right-click on the Metasploitable VM and select "Settings".
   - Go to the "Network" tab.
   - Ensure that "Adapter 1" is enabled and set to "Host-only Adapter".
7. Start the VMs by selecting it and clicking "Start".
8. Wait for the VMs to boot up completely.
9. You can minimize the metasploitable VM after it has started, as we will interact with it from the it-security-training VM.
10. Log in to the it-security-training VM with the following credentials:
   - Username: kali
   - Password: kali


## Introduction to IT Security

See [Introduction-to-IT-Security](./Introduction-to-IT-Security)

## API Security

See [API-Security-Training](./API-Security-Training)

## Web Security

See [Web-Security](./Web-Security)