#!/usr/bin/env bash
set -eux

# Update and install essential packages
sudo apt-get update -y
sudo apt-get install -y \
  qemu-guest-agent \
  curl \
  wget \
  vim \
  net-tools \
  openssh-server

# Create ubuntu user if it doesn't exist
if ! id "ubuntu" &>/dev/null; then
  sudo useradd -m -s /bin/bash ubuntu
  echo "ubuntu:ubuntu" | sudo chpasswd
  sudo usermod -aG sudo ubuntu
  echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/ubuntu
  sudo chmod 440 /etc/sudoers.d/ubuntu
fi

# Configure SSH
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Enable and start services
sudo systemctl enable ssh
sudo systemctl restart ssh
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent
