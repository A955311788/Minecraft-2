# Automated Minecraft Server Deployment on AWS

## Project Goal

This project automates the deployment of a Minecraft server on AWS using AWS Learner Lab, WSL Ubuntu, and Visual Studio Code.

The Minecraft server runs on an Ubuntu EC2 instance. Terraform creates the AWS resources, and Ansible configures the server. no user SSH required.

This project uses Minecraft Java Server 1.21.4. users need to install Minecraft Java Edition 1.21.4 on their client when connecting to the server. This version is used because AWS Academy / AWS Learner Lab commonly uses Ubuntu packages with Java 21. Newer Minecraft server versions may require a newer Java runtime, which can cause a Java class version mismatch and stop the server from functioning properly.

GitHub repo to clone:

```text
https://github.com/A955311788/Minecraft-2.git
```

This project uses:

* AWS Learner Lab for AWS access
* WSL Ubuntu as the Linux terminal 
* Visual Studio Code for editing and running the project
* AWS CLI for connecting to AWS
* Terraform for creating AWS infrastructure
* Ansible for configuring the Minecraft server
* nmap for testing the Minecraft port
* Minecraft Java Edition 1.21.4 for connecting to the server

## Programs/services needed

Before starting, install these:

* Visual Studio Code
* WSL Ubuntu
* VS Code WSL extension
* AWS CLI
* Terraform
* Ansible
* nmap
* Git
* Minecraft Java Edition

This project will run from WSL Ubuntu, not PowerShell or regular Git Bash. WSL is recommended because Ansible works best in a Linux environment.

## How to install WSL Ubuntu

Open PowerShell as Administrator and run:

```bash
wsl --install -d Ubuntu
```

After installation finishes, restart your computer if needed. Then open wsl Ubuntu from the Start Menu and create your Linux username and password.

## Install the VS Code WSL Extension

Open Visual Studio Code.

Go to:

```text
Extensions
```

Search for:

```text
WSL
```

Install the official WSL extension from Microsoft.

This allows VS Code to open and edit files directly inside WSL Ubuntu.

## Install Required Tools in WSL Ubuntu

Open the Ubuntu terminal and run:

```bash
sudo apt update && sudo apt install -y git curl unzip wget gpg nmap ansible
```

Install AWS CLI:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sudo ./aws/install
```

Install Terraform:

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list && sudo apt update && sudo apt install -y terraform
```

Check that all tools are installed:

```bash
git --version && aws --version && terraform --version && ansible --version && nmap --version
```

If all commands return version numbers, the services are installed.

## Open the Project in VS Code Using WSL

In WSL Ubuntu, clone the repository:

```bash
git clone https://github.com/A955311788/Minecraft-2.git && cd Minecraft-2
```

Then open the project in Visual Studio Code by running:

```bash
code .
```

This command opens the current WSL project folder in VS Code. Please make sure the correct directory for the project is selected if not enter
cd "directory name" 
ex. cd Minecraft-2. 

In the bottom-left corner of VS Code, you should see something like:

```text
WSL: Ubuntu
```

That means VS Code is connected to WSL.

## Step 1: Start AWS Learner Lab

Go to  AWS Learner Lab page.

Click:

```text
Start Lab
```

Wait until the lab indicator turns green.

Then click:

```text
AWS Details
```

Copy your temporary AWS credentials.

You should see values like:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
```

These credentials are temporary and only work while the Learner Lab session is active.

## Step 2: Configure AWS Credentials in WSL

In the VS Code WSL terminal, export your AWS Learner Lab credentials:

```bash
export AWS_ACCESS_KEY_ID="your_access_key"
```

```bash
export AWS_SECRET_ACCESS_KEY="your_secret_key"
```

```bash
export AWS_SESSION_TOKEN="your_session_token"
```

```bash
export AWS_DEFAULT_REGION="us-east-1"
```

Replace the "" values with the real values from AWS Learner Lab.

Test the AWS connection:

```bash
aws sts get-caller-identity
```

If this returns AWS account information, your credentials are working.

## Step 3: Create an EC2 Key Pair

Ansible needs an EC2 key pair to configure the Ubuntu server after Terraform creates it.

From the VS Code WSL terminal, run:

```bash
aws ec2 create-key-pair --key-name minecraft-key --query 'KeyMaterial' --output text > minecraft-key.pem
```

## Step 4: Retrieve Your Local Public IP Address

Retrieve your local public IP address. The security group uses this IP address so only your computer can access SSH and the Minecraft server.

When using your public IP address in the deploy command, add `/32` to the end.

Example:

```text
203.0.113.25/32
```

## Step 5: Make Scripts Executable

Run this command from inside the project folder:

```bash
chmod +x scripts/*.sh
```

This gives permission to run the deployment and testing scripts.

## Step 6: Start the Minecraft Server

Run the deployment script:

```bash
./scripts/deploy.sh --key-name "minecraft-key" --private-key "./minecraft-key.pem" --allowed-ip "YOUR_PUBLIC_IP/32" --rcon-password "ChangeThisPassword123!"
```

Replace:

* `minecraft-key` with your EC2 key pair name
* `./minecraft-key.pem` with the path to your private key file
* `YOUR_PUBLIC_IP/32` with your public IP address
* `ChangeThisPassword123!` with a secure RCON password

Example:

```bash
./scripts/deploy.sh --key-name "minecraft-key" --private-key "./minecraft-key.pem" --allowed-ip "203.0.113.25/32" --rcon-password "MySecurePassword123!"
```

This script will automatically:

1. Run Terraform
2. Create an Ubuntu EC2 instance
3. Create a security group
4. Open port `22` for Ansible
5. Open port `25565` for Minecraft
6. Get the EC2 public IP address
7. Create an Ansible inventory file
8. Run the Ansible playbook
9. Install Java and required packages
10. Download and configure Minecraft Server 1.21.4
11. Create the Minecraft `systemd` service
12. Start the Minecraft server

## Step 7: Test the Minecraft Server

After deployment finishes, run:

```bash
./scripts/test.sh
```

If the server is working, port `25565` should show as open.

## Step 8: Connect from Minecraft Java Edition

Open **Minecraft Java Edition 1.21.4**.

Go to:

```text
Multiplayer > connect dirtectly 
```

For the server address, enter:

```text
<instance_public_ip>
```

Example:

```text
54.123.45.67
```

Click **connect/done**, and join the server.

If the Minecraft client says **Incompatible Client**, make sure the launcher is using **Minecraft Java Edition 1.21.4**.

## Restart Behavior

The Minecraft server runs as a Linux `systemd` service named `minecraft`.

This means the server should automatically start again if the EC2 instance reboots.

The service also uses a safe shutdown command. It sends Minecraft the `save-all` and `stop` commands before stopping the service. This helps protect the Minecraft world from corruption.

## Stack Pipeline

1. The user starts AWS Learner Lab.
2. The user exports AWS Learner Lab credentials in WSL.
3. Terraform provisions the AWS infrastructure.
4. Terraform creates the Ubuntu EC2 instance and security group.
5. Terraform outputs the public IP address of the EC2 instance.
6. The deployment script creates an Ansible inventory file.
7. Ansible connects to the EC2 instance.
8. Ansible installs Java and required Linux packages.
9. Ansible downloads and configures Minecraft Server 1.21.4.
10. Ansible creates and enables the Minecraft `systemd` service.
11. Minecraft starts automatically.
12. The user tests port `25565` with nmap.
13. The user connects from Minecraft Java Edition 1.21.4.

## Resources Used

* Terraform AWS Provider Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
* AWS CLI Documentation: https://docs.aws.amazon.com/cli/
* AWS EC2 Documentation: https://docs.aws.amazon.com/ec2/
* AWS EC2 Security Groups Documentation: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security-groups.html
* Ansible Documentation: https://docs.ansible.com/
* Ansible systemd_service Module: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_service_module.html
* nmap Documentation: https://nmap.org/docs.html
* Minecraft Official Website: https://www.minecraft.net/
* Minecraft Launcher Version Guide: https://help.minecraft.net/hc/en-us/articles/360034754852-Change-Game-Versions-for-Minecraft-Java-Edition
