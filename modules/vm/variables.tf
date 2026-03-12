variable "zone" {
  type = string
}

variable "vms" {
  type = map(object({
    cores         = number
    memory        = number
    disk_size     = number
    core_fraction = number
    preemptible   = bool
    ip_address    = string
    hostname      = string
    platform_id   = optional(string, "standard-v3")
    nat           = optional(bool, false)
    role          = string
  }))
}

variable "image_id" {
  type = string
}

variable "subnet_id" {
  description = "Берётся из outputs модуля network"
  type        = string
}

variable "sg_id" {
  description = "Берётся из outputs модуля security_group"
  type        = string
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

variable "ssh_port" {
  type    = number
  default = 22
}

variable "environment" {
  type    = string
  default = "dev"
}
