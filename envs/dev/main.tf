# ─── Modules ───────────────────────────────────────────────────────────────────

module "networks" {
  source      = "../../modules/networks"
  zone        = var.zone
  subnet_cidr = var.subnet_cidr
}

module "security_group" {
  source      = "../../modules/security_group"
  network_id  = module.networks.network_id
  subnet_cidr = var.subnet_cidr
  ssh_port    = var.ssh_port
}

module "vm" {
  source         = "../../modules/vm"
  zone           = var.zone
  vms            = var.vms
  image_id       = var.image_id
  subnet_id      = module.networks.subnet_id
  sg_id          = module.security_group.sg_id
  ssh_public_key = var.ssh_public_key
  ssh_port       = var.ssh_port
  environment    = "dev"
}

# ─── Outputs ───────────────────────────────────────────────────────────────────

output "admin_external_ip" {
  value = module.vm.admin_external_ip
}

output "all_internal_ips" {
  value = module.vm.all_internal_ips
}
