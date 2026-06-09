#!/usr/bin/env bash
set -euo pipefail

KEY_NAME=""
PRIVATE_KEY=""
ALLOWED_IP=""
RCON_PASSWORD_VALUE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --key-name)
      KEY_NAME="$2"
      shift 2
      ;;
    --private-key)
      PRIVATE_KEY="$2"
      shift 2
      ;;
    --allowed-ip)
      ALLOWED_IP="$2"
      shift 2
      ;;
    --rcon-password)
      RCON_PASSWORD_VALUE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$KEY_NAME" || -z "$PRIVATE_KEY" || -z "$ALLOWED_IP" || -z "$RCON_PASSWORD_VALUE" ]]; then
  echo "Usage:"
  echo "./scripts/deploy.sh --key-name KEY_NAME --private-key PATH_TO_PEM --allowed-ip YOUR_IP/32 --rcon-password PASSWORD"
  exit 1
fi

chmod 400 "$PRIVATE_KEY"

echo "[1/4] Provisioning AWS infrastructure with Terraform..."
cd terraform

terraform init
terraform apply -auto-approve \
  -var="key_name=$KEY_NAME" \
  -var="allowed_ip_cidr=$ALLOWED_IP"

PUBLIC_IP=$(terraform output -raw public_ip)

cd ..

echo "[2/4] Creating Ansible inventory..."
cat > ansible/inventory.ini <<EOF
[minecraft]
$PUBLIC_IP ansible_user=ubuntu ansible_ssh_private_key_file=$PRIVATE_KEY
EOF

echo "[3/4] Waiting for instance SSH to become ready..."
sleep 45

echo "[4/4] Configuring Minecraft server with Ansible..."
export RCON_PASSWORD="$RCON_PASSWORD_VALUE"

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
  -i ansible/inventory.ini \
  ansible/playbook.yml

echo
echo "Deployment complete."
echo "Minecraft server address: $PUBLIC_IP:25565"
