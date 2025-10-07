#!/usr/bin/env bash
set -eux

# Update and install essential packages
sudo apt-get update -y
sudo apt-get install -y \
  qemu-guest-agent \
  curl \
  wget \
  vim \
  net-tools

# Enable and start qemu-guest-agent
sudo systemctl enable qemu-guest-agent
