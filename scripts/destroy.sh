#!/usr/bin/env bash
set -euo pipefail

cd terraform
terraform destroy -auto-approve
