# ─── Security Group ─────────────────────────────────────────────────────────────

resource "yandex_vpc_security_group" "main" {
  name       = var.sg_name
  network_id = var.network_id

  ingress {
    protocol       = "TCP"
    description    = "SSH custom port"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = var.ssh_port
  }

#  ingress {
#    protocol       = "TCP"
#    description    = "SSH port 22 (temporary)"
#    v4_cidr_blocks = ["0.0.0.0/0"]
#    port           = 22
#  }

  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API (internal only)"
    v4_cidr_blocks = [var.subnet_cidr]
    port           = 6443
  }

  ingress {
    protocol       = "ANY"
    description    = "Internal cluster communication"
    v4_cidr_blocks = [var.subnet_cidr]
  }

  ingress {
    protocol       = "ICMP"
    description    = "Ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "All outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
