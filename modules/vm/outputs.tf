output "admin_external_ip" {
  value = yandex_compute_instance.vms["admin"].network_interface[0].nat_ip_address
}

output "all_internal_ips" {
  value = {
    for name, vm in yandex_compute_instance.vms :
    name => {
      ip       = vm.network_interface[0].ip_address
      hostname = vm.hostname
      role     = var.vms[name].role
    }
  }
}
