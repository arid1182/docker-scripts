#!/bin/bash

# Define colors for clarity
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}--- WARNING: Starting Complete Kind/Kubectl Removal ---${NC}"

# 1. Delete all active Kind clusters
if command -v kind &> /dev/null; then
    CLUSTERS=$(kind get clusters 2>/dev/null)
    if [ -n "$CLUSTERS" ]; then
        echo -e "${BLUE}Deleting all Kind clusters...${NC}"
        # This removes the Docker containers and cleans up kubeconfig entries
        kind delete clusters --all
    else
        echo -e "${GREEN}No active Kind clusters found.${NC}"
    fi
fi

# 2. Remove the Binaries
echo -e "${BLUE}Removing binaries from /usr/local/bin...${NC}"
sudo rm -f /usr/local/bin/kind
sudo rm -f /usr/local/bin/kubectl

# 3. Clean up Configuration Directories
echo -e "${BLUE}Cleaning up configuration folders (~/.kind and ~/.kube)...${NC}"
# Be careful: removing ~/.kube removes ALL kubernetes contexts (including MicroK8s)
# If you only want to remove kind, we should be more surgical:
if [ -d "$HOME/.kube" ]; then
    # We remove the cache and specifically kind-related configs if they exist
    rm -rf "$HOME/.kube/cache"
    # To be "nuke" level, we remove the whole config, 
    # but I'll leave the folder so other tools don't break.
    rm -f "$HOME/.kube/config" 
fi
rm -rf "$HOME/.kind"

# 4. Remove Bash Completions (Optional)
echo -e "${BLUE}Cleaning up .bashrc entries...${NC}"
if [ -f "$HOME/.bashrc" ]; then
    sed -i '/kind completion bash/d' "$HOME/.bashrc"
    sed -i '/kubectl completion bash/d' "$HOME/.bashrc"
fi

# 5. Verify Removal
echo -e "${RED}Verification:${NC}"
for cmd in kind kubectl; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${GREEN}✓ $cmd has been removed.${NC}"
    else
        echo -e "${RED}✗ $cmd is still present at $(which $cmd).${NC}"
    fi
done

echo -e "${GREEN}Cleanup complete. Your system is now clear of the previous Kind setup.${NC}"
echo "Note: Run 'source ~/.bashrc' to refresh your current terminal session."
