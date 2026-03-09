# ─── Network ───────────────────────────────────────────────────────────────────

resource "yandex_vpc_network" "main" {
  name = "main-network"
}

resource "yandex_vpc_subnet" "main" {
  name           = "main-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.subnet_cidr]
}

# ─── Security Group ─────────────────────────────────────────────────────────────

resource "yandex_vpc_security_group" "main" {
  name       = "main-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = var.ssh_port
  }

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

# ─── SSH Key & User-Data ────────────────────────────────────────────────────────

locals {
  ssh_public_key = file(var.ssh_public_key_path)

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Обновляем пакеты
    apt update && apt upgrade -y

    # Разрешаем root вход по SSH
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

    # Меняем порт SSH
    sed -i 's/^Port 22/Port ${var.ssh_port}/' /etc/ssh/sshd_config

    # Добавляем SSH ключ для root
    mkdir -p /root/.ssh
    echo "${local.ssh_public_key}" >> /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys

    # Перезапускаем SSH
    reboot
  EOF
}

# ─── Virtual Machines ───────────────────────────────────────────────────────────

resource "yandex_compute_instance" "vms" {
  for_each = var.vms

  name        = each.key
  hostname    = each.value.hostname
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = each.value.cores
    memory        = each.value.memory
    core_fraction = each.value.core_fraction
  }

  scheduling_policy {
    preemptible = each.value.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = each.value.disk_size
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.main.id
    security_group_ids = [yandex_vpc_security_group.main.id]
    ip_address         = each.value.ip_address
    nat                = each.value.nat
  }

  metadata = {
    user-data = local.user_data
  }

  labels = {
    environment = "dev"
    managed_by  = "terraform"
    role        = each.value.role
  }
}

# ─── Outputs ────────────────────────────────────────────────────────────────────

output "admin_external_ip" {
  description = "Публичный IP admin (SSH jump host)"
  value       = yandex_compute_instance.vms["admin"].network_interface[0].nat_ip_address
}

output "all_internal_ips" {
  description = "Внутренние IP всех ВМ"
  value = {
    for name, vm in yandex_compute_instance.vms :
    name => {
      ip       = vm.network_interface[0].ip_address
      hostname = var.vms[name].hostname
      role     = var.vms[name].role
    }
  }
}

