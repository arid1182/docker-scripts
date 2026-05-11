#!/bin/sh
set -e

# Amazon Linux Docker installation script.
# This mimics the behavior of https://get.docker.com/ for Amazon Linux environments.

# 1. Detect Amazon Linux Version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    VERSION=$VERSION_ID
else
    echo "Error: Could not detect operating system."
    exit 1
fi

if [ "$DISTRO" != "amzn" ]; then
    echo "Error: This script is specifically for Amazon Linux. Detected: $DISTRO"
    exit 1
fi

echo "# Executing Docker install script for $PRETTY_NAME"

# 2. Perform Installation based on version
if [ "$VERSION" = "2023" ]; then
    # Amazon Linux 2023 uses dnf
    sudo dnf update -y
    sudo dnf install -y docker
elif [ "$VERSION" = "2" ]; then
    # Amazon Linux 2 (AL2) uses amazon-linux-extras
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
else
    # Older Amazon Linux AMI
    sudo yum install -y docker
fi

# 3. Start and Enable Docker Service
echo "# Starting and enabling Docker service..."
sudo systemctl enable docker.service
sudo systemctl start docker.service

# 4. Post-installation info (mimicking get.docker.com)
echo "================================================================================"
echo "Docker installed successfully!"
echo ""
echo "To run Docker as a non-root user (e.g., the 'ec2-user'), run:"
echo "  sudo usermod -aG docker \$USER"
echo ""
echo "Remember to log out and back in for this to take effect."
echo "================================================================================"
