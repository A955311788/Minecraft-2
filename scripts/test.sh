#!/usr/bin/env bash
set -euo pipefail

cd terraform
PUBLIC_IP=$(terraform output -raw public_ip)
cd ..

echo "Testing Minecraft port on $PUBLIC_IP..."
nmap -sV -Pn -p T:25565 "$PUBLIC_IP"
