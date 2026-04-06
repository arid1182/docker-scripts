#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting kind installation...${NC}"

# 1. Detect CPU Architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64) KIND_ARCH="amd64" ;;
    aarch64) KIND_ARCH="arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# 2. Set Version (Latest stable as of early 2026)
KIND_VERSION="v0.26.0"

echo -e "${BLUE}Downloading kind ${KIND_VERSION} for ${KIND_ARCH}...${NC}"

# 3. Download the binary
# Using -L to follow redirects and -o to specify output location
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${KIND_ARCH}"

# 4. Make the binary executable
chmod +x ./kind

# 5. Move to /usr/local/bin (requires sudo)
echo -e "${BLUE}Moving kind to /usr/local/bin...${NC}"
sudo mv ./kind /usr/local/bin/kind

# 6. Verify Installation
echo -e "${GREEN}Installation complete! Verification:${NC}"
kind version

# 7. Add shell completion (optional but recommended for productivity)
if [ -f ~/.bashrc ]; then
    if ! grep -q "kind completion bash" ~/.bashrc; then
        echo "source <(kind completion bash)" >> ~/.bashrc
        echo -e "${BLUE}Bash completion added to ~/.bashrc${NC}"
    fi
fi

echo -e "${GREEN}Successfully installed kind!${NC}"
