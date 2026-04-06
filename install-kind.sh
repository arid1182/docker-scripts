#!/bin/bash

set -e

# --- Configuration ---
KIND_VERSION="v0.31.0"
K8S_VERSION="v1.35.0"
# For v1.34, change to: "v1.34.0"
NODE_IMAGE="kindest/node:${K8S_VERSION}@sha256:452d707d4862f52530247495d180205e029056831160e22870e37e3f6c1ac31f"

# --- 1. Install Kind Binary ---
ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')

if ! command -v kind &> /dev/null; then
    echo "Installing kind ${KIND_VERSION}..."
    curl -Lo ./kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${ARCH}"
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
else
    echo "Kind is already installed: $(kind version)"
fi

# --- 2. CI/CD Optimized Cluster Creation ---
# Check if cluster already exists to prevent errors in re-runnable pipelines
if ! kind get clusters | grep -q "^ci-cluster$"; then
    echo "Creating CI/CD cluster with K8s ${K8S_VERSION}..."
    kind create cluster --name api-gateway --image "$NODE_IMAGE" --wait 5m
else
    echo "Cluster 'ci-cluster' already exists. Skipping creation."
fi

echo "Kubeconfig is ready. Testing connection..."
kubectl cluster-info
