variable "zone" {
  description = "Availability zone"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR block"
  type        = string
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "main-network"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "main-subnet"
}
