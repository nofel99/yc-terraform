variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR — для internal правил"
  type        = string
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 22
}

variable "sg_name" {
  description = "Security group name"
  type        = string
  default     = "main-sg"
}
