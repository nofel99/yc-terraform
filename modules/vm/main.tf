# ─── locals ────────────────────────────────────────────────────────────────────

locals {
  user_data_admin = templatefile("${path.root}/meta-admin.yml", {
    ssh_public_key = var.ssh_public_key
    ssh_port       = var.ssh_port
  })

  user_data_node = templatefile("${path.root}/meta-node.yml", {
    ssh_public_key = var.ssh_public_key
  })
}

# ─── Virtual Machines ───────────────────────────────────────────────────────────

resource "yandex_compute_instance" "vms" {
  for_each = var.vms

  name        = each.key
  hostname    = each.value.hostname
  platform_id = each.value.platform_id
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
    subnet_id          = var.subnet_id
    security_group_ids = [var.sg_id]
    ip_address         = each.value.ip_address
    nat                = each.value.nat
  }

  metadata = {
    user-data          = each.key == "admin" ? local.user_data_admin : local.user_data_node
    serial-port-enable = "1"
    enable-oslogin     = "true"
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
    role        = each.value.role
  }
}
