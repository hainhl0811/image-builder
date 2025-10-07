#!/usr/bin/env bash
set -eux

# Update and install essential packages for OpenStack
sudo apt-get update -y
sudo apt-get install -y \
  cloud-init \
  cloud-guest-utils \
  cloud-initramfs-growroot \
  qemu-guest-agent \
  curl \
  wget \
  vim \
  net-tools

# Configure cloud-init for OpenStack
sudo tee /etc/cloud/cloud.cfg.d/99-openstack.cfg > /dev/null <<EOF
# OpenStack-specific cloud-init configuration
datasource_list: [ OpenStack, None ]
datasource:
  OpenStack:
    metadata_urls: ['http://169.254.169.254']
    max_wait: 120
    timeout: 10

# Enable growing root partition
growpart:
  mode: auto
  devices: ['/']

# Preserve hostname set by cloud-init
preserve_hostname: false

# Enable password authentication (can be disabled via cloud-init user-data in OpenStack)
ssh_pwauth: false

# Cleanup existing keys on first boot
ssh_deletekeys: true
ssh_genkeytypes: ['rsa', 'ecdsa', 'ed25519']
EOF

# Enable and start qemu-guest-agent
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent

# Ensure cloud-init runs on first boot
sudo systemctl enable cloud-init cloud-init-local cloud-config cloud-final
