packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

variable "ubuntu_codename" {
  type        = string
  default     = "jammy"
  description = "Ubuntu codename version"
}

variable "file_name_root" {
  type        = string
  default     = "cloud_image_x86_64"
  description = "File name root"
}

variable "accelerator" {
  type        = string
  default     = "none"
  description = "QEMU accelerator"
}

source "qemu" "ubuntu" {
  accelerator = var.accelerator
  cd_files = ["./cloud-init/*"]
  cd_label = "cidata"
  disk_compression = true
  disk_image = true
  disk_size = "10G"
  headless = true
  iso_checksum = "file:https://cloud-images.ubuntu.com/${var.ubuntu_codename}/current/SHA256SUMS"
  iso_url = "https://cloud-images.ubuntu.com/${var.ubuntu_codename}/current/${var.ubuntu_codename}-server-cloudimg-amd64.img"
  output_directory = "output"
  qemuargs = [
    ["-m", "2048M"],
    ["-smp", "2"],
    ["-serial", "mon:stdio"]
  ]
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password = "ubuntu"
  ssh_username = "ubuntu"
  vm_name = "${var.file_name_root}_${var.ubuntu_codename}.img"
}

build {
  sources = ["source.qemu.ubuntu"]
  provisioner "file" {
    source      = "./script/logger.sh"
    destination = "/tmp/logger.sh"
  }
  provisioner "shell" {
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    scripts = [
      "./script/cloud-init.sh",
      "./script/install/apt.sh",
      "./script/install/docker.sh",
      "./script/install/act.sh",
      "./script/cleanup.sh"
    ]
  }
}
