# ─── Provider ──────────────────────────────────────────────────────────────────

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

# ─── Network ───────────────────────────────────────────────────────────────────

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "subnet_cidr" {
  description = "Subnet CIDR block"
  type        = string
}

# ─── Security ──────────────────────────────────────────────────────────────────

variable "ssh_port" {
  description = "Custom SSH port"
  type        = number
  default     = 22
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

# ─── Virtual Machines ──────────────────────────────────────────────────────────

variable "image_id" {
  description = "Boot disk image ID"
  type        = string
}

variable "vms" {
  description = "Map of VMs to create"
  type = map(object({
    hostname      = string
    platform_id   = optional(string, "standard-v3")
    cores         = number
    memory        = number
    core_fraction = number
    preemptible   = bool
    disk_size     = number
    ip_address    = string
    nat           = bool
    role          = string
  }))
}
