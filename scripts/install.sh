#!/usr/bin/env bash
set -eux
sudo apt-get update -y
sudo apt-get install -y qemu-guest-agent cloud-init curl
