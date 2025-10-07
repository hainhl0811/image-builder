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
  iso_url          = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum     = "file:https://releases.ubuntu.com/22.04/SHA256SUMS"
  output_directory = "output/${var.image_name}"

  # qcow2 output format
  format     = "qcow2"
  disk_size  = 20480    # 20GB
  accelerator = "kvm"
  headless    = true

  http_directory = "http"  # will serve cloud-init (user-data/meta-data)

  ssh_username = "ubuntu"   # autoinstall will create user 'ubuntu' per user-data below
  ssh_password = "ubuntu"   # temporary password set in user-data
  ssh_timeout  = "30m"

  # Example kernel bootline for Ubuntu autoinstall — you may need to tweak timing/paths for different ISOs
  boot_command = [
    "<esc><wait>",
    "set gfxpayload=1024x768<enter>",
    "/casper/vmlinuz ",
    "autoinstall ",
    "ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "quiet --- <enter>"
  ]

  boot_wait = "5s"
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
