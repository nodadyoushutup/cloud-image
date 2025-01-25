packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

variable "accelerator" {
  type = string
  default = "none"
  description = "QEMU accelerator"
}

variable "output_dir" {
  type = string
  default = "output"
  description = "Output directory"
}

variable "file_name" {
  type = string
  default = "cloud_image_x86_64_jammy"
  description = "File name"
}

source "qemu" "ubuntu" {
  accelerator = var.accelerator
  cd_files = ["./cloud_init/*"]
  cd_label = "cidata"
  disk_compression = true
  disk_image = true
  disk_size = "10G"
  headless = true
  iso_checksum = "file:https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS"
  iso_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  output_directory = var.output_dir
  qemuargs = [
    ["-m", "2048M"],
    ["-smp", "2"],
    ["-serial", "mon:stdio"]
  ]
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password = "packer"
  ssh_username = "packer"
  vm_name = "${var.file_name}.img"
}

build {
  sources = ["source.qemu.ubuntu"]

  provisioner "file" {
    source      = "./file/node_exporter.service"
    destination = "/tmp/node_exporter.service"
  }

  provisioner "file" {
    source      = "./file/sshd_config"
    destination = "/tmp/sshd_config"
  }

  provisioner "shell" {
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    scripts = [
      "./script/cloud_init.sh",
      "./script/sshd.sh",
      "./script/apt.sh",
      "./script/docker.sh",
      "./script/terraform.sh",
      "./script/ansible.sh",
      "./script/act.sh",
      "./script/node_exporter.sh",
      "./script/packer.sh",
      "./script/user_group.sh",
      "./script/directory.sh",
      "./script/cleanup.sh"
    ]
  }
}