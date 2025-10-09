packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "image_name" {
  type    = string
  default = "ubuntu-22.04-base"
}

variable "ssh_authorized_key" {
  type    = string
  default = "" # replace via env/CI secret or with your key
}

source "qemu" "ubuntu" {
  # Use Ubuntu cloud image instead of ISO installation
  iso_url          = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  iso_checksum     = "file:https://cloud-images.ubuntu.com/releases/22.04/release/SHA256SUMS"
  output_directory = "output/${var.image_name}"

  # qcow2 output format
  format           = "qcow2"
  disk_size        = "20G"
  disk_interface   = "virtio"
  net_device       = "virtio-net"
  accelerator      = "kvm"
  headless         = true
  vnc_bind_address = "0.0.0.0"
  qemuargs = [
    ["-cpu", "host"],
    ["-m", "2048M"]
  ]

  http_directory = "http"  # serves cloud-init user-data

  ssh_username = "ubuntu"   # cloud image default user
  ssh_password = "ubuntu"   # will be set via cloud-init
  ssh_timeout  = "10m"      # cloud images boot much faster

  # No boot command needed - cloud image boots directly
}

build {
  name    = "ubuntu-qcow2"
  sources = ["source.qemu.ubuntu"]

  # Add SSH key if provided
  provisioner "shell" {
    inline = [
      "mkdir -p ~/.ssh",
      "chmod 700 ~/.ssh",
      "if [ -n '${var.ssh_authorized_key}' ]; then echo '${var.ssh_authorized_key}' >> ~/.ssh/authorized_keys; fi",
      "chmod 600 ~/.ssh/authorized_keys"
    ]
  }

  provisioner "shell" {
    script = "scripts/install.sh"
  }

  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }

  # final artifact location
  post-processor "compress" {
    output = "artifacts/${var.image_name}.qcow2"
  }
}
