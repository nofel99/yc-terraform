variable "token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-d"
}

variable "subnet_cidr" {
  description = "Subnet CIDR block"
  type        = string
  default     = "10.10.101.0/24"
}

variable "image_id" {
  description = "Boot image ID (Ubuntu 24.04 LTS)"
  type        = string
  default     = "fd8kgf1n4lk46ce8mrvg"
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}

variable "vms" {
  description = "Virtual machines configuration"
  type = map(object({
    cores         = number
    memory        = number
    disk_size     = number
    core_fraction = number
    preemptible   = bool
    ip_address    = string
    hostname      = string
    nat           = bool
    role          = string
  }))
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 22
}
