#!/bin/bash
set -e

# --- Configuration ---
KIND_VERSION="v0.31.0"
# This fetches the string "v1.34.2" or similar automatically
STABLE_K8S=$(curl -L -s https://dl.k8s.io/release/stable.txt)
ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')

echo -e "Installing stable kubectl (${STABLE_K8S})..."

# --- Install Kubectl ---
curl -LO "https://dl.k8s.io/release/${STABLE_K8S}/bin/linux/${ARCH}/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
