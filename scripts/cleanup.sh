#!/usr/bin/env bash
set -eux
sudo apt-get autoremove -y
sudo apt-get clean
sudo rm -rf /tmp/* /var/tmp/*
sudo cloud-init clean --logs
history -c
