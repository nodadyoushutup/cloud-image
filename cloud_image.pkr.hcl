packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

variable "build_type" {
  type = string
  default = "local"
  description = "Build local or remote"
}

variable "ubuntu_codename" {
  type        = string
  default     = "jammy"
  description = "Ubuntu codename version"
}

variable "output_dir" {
  type        = string
  default     = "output"
  description = "Output directory"
}

variable "file_name_root" {
  type        = string
  default     = "nodadyoushutup_cloud_image"
  description = "File name root"
}

source "qemu" "ubuntu" {
  accelerator      = var.build_type == "local" ? "kvm" : "none"
  cd_files         = ["./cloud-init/*"]
  cd_label         = "cidata"
  disk_compression = true
  disk_image       = true
  disk_size        = "10G"
  headless         = true
  iso_checksum     = "file:https://cloud-images.ubuntu.com/${var.ubuntu_codename}/current/SHA256SUMS"
  iso_url          = "https://cloud-images.ubuntu.com/${var.ubuntu_codename}/current/${var.ubuntu_codename}-server-cloudimg-amd64.img"
  output_directory = var.output_dir
  qemuargs         = [
    ["-m", "2048M"],
    ["-smp", "2"],
    ["-serial", "mon:stdio"]
  ]
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password     = "ubuntu"
  ssh_username     = "ubuntu"
  vm_name          = "${var.file_name_root}_${var.ubuntu_codename}.img"
}

build {
  sources = ["source.qemu.ubuntu"]
  provisioner "shell" {
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    scripts = [
      "./script/cloud-init.sh",
      "./script/install/apt.sh",
      "./script/install/docker.sh",
      "./script/cleanup.sh"
    ]
  }
}
