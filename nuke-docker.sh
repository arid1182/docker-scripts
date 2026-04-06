#!/usr/bin/env bash
set -euo pipefail

# Must run as root
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root: sudo ./nuke-docker.sh"
  exit 1
fi

echo "=============================="
echo " Docker Full Cleanup Script"
echo " Ubuntu / Debian"
echo "=============================="
echo

# Check if docker command exists
if ! command -v docker &> /dev/null; then
  echo "Docker CLI not found. Will proceed to package cleanup only."
else
  echo "---- Current Docker State ----"
  echo
  echo "Containers:"
  docker ps -a || true
  echo
  echo "Images:"
  docker images || true
  echo
  echo "Volumes:"
  docker volume ls || true
  echo
fi

echo
read -p "This will DELETE EVERYTHING related to Docker. Continue? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
  echo "Aborted."
  exit 0
fi

echo
echo "---- Removing containers ----"
if command -v docker &> /dev/null; then
  docker rm -f $(docker ps -aq) 2>/dev/null || true
fi

echo "---- Removing images ----"
if command -v docker &> /dev/null; then
  docker rmi -f $(docker images -q) 2>/dev/null || true
fi

echo "---- Removing volumes ----"
if command -v docker &> /dev/null; then
  docker volume rm $(docker volume ls -q) 2>/dev/null || true
fi

echo "---- Stopping Docker service ----"
systemctl stop docker 2>/dev/null || true
systemctl stop containerd 2>/dev/null || true

echo "---- Removing Docker packages ----"
apt-get purge -y \
  docker-ce \
  docker-ce-cli \
  docker-ce-rootless-extras \
  docker-buildx-plugin \
  docker-compose-plugin \
  docker.io \
  containerd.io || true

apt-get autoremove -y
apt-get autoclean

echo "---- Removing Docker data directories ----"
rm -rf /var/lib/docker
rm -rf /var/lib/containerd
rm -rf /etc/docker

echo
echo "---- Removing Docker group (if exists) ----"
groupdel docker 2>/dev/null || true

echo
echo "---- Final check ----"
if command -v docker &> /dev/null; then
  echo "Docker binary still present at: $(which docker)"
else
  echo "Docker successfully removed from system."
fi

echo
echo "DONE. System is clean from Docker."
