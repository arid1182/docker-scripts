#!/bin/bash
# --- CONFIGURATION ---
ARCH=$(uname -m)
INSTALL_DIR="/usr/local/bin"

echo "------------------------------------------------"
echo "🚀 Starting AWS Developer Tools Setup/Upgrade"
echo "------------------------------------------------"

# 1. Update OS package manager and install dependencies
echo "📦 Installing system dependencies..."
sudo apt-get update -y
sudo apt-get install -y unzip curl jq docker.io

# 2. Setup Docker permissions (allows running SAM without sudo)
echo "🐳 Configuring Docker permissions..."
sudo usermod -aG docker $USER
# Note: You may need to logout and back in for this to take effect

# 3. AWS CLI v2 Installation/Upgrade
echo "☁️ Processing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "awscliv2.zip"
unzip -u awscliv2.zip
sudo ./aws/install --bin-dir $INSTALL_DIR --install-dir /usr/local/aws-cli --update
rm -rf aws awscliv2.zip

# 4. AWS SAM CLI Installation/Upgrade
echo "⚡ Processing AWS SAM CLI..."
# Determine the correct SAM installer for the architecture
if [ "$ARCH" == "x86_64" ]; then
    SAM_URL="https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip"
else
    SAM_URL="https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-arm64.zip"
fi

curl -L "$SAM_URL" -o "aws-sam-cli.zip"
unzip -u aws-sam-cli.zip -d sam-installation
sudo ./sam-installation/install --update
rm -rf sam-installation aws-sam-cli.zip

# 5. AWS HashiCorp Terraform Installion/Upgrade
echo "⚡ Processing AWS Terraformharshicorp ..."
sudo apt-get install -y gnupg software-properties-common curl unzip
echo "Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
echo "Verifying installations..."
echo "Installation complete! To configure your AWS credentials, run: 'aws configure'"

echo "------------------------------------------------"
echo "✅ Setup Complete! Versions installed:"
aws --version
sam --version
docker --version
terraform -version
echo "------------------------------------------------"
echo "💡 TIP: Please log out and back in to use Docker without sudo."
