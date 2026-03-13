# Terraform — Yandex Cloud
Инфраструктура Yandex Cloud на Terraform. Kubernetes кластер из 3 VM за jump host.

## Структура
```
envs/dev/         # окружение dev (backend, variables, tfvars)
modules/
  networks/       # VPC, subnet, NAT gateway
  security_group/ # firewall правила
  vm/             # виртуальные машины
```

## Быстрый старт

**1. Создать секреты backend** `envs/dev/backend.hcl`:
```hcl
bucket     = "your-bucket"
access_key = "your-access-key"
secret_key = "your-secret-key"
```

**2. Заполнить переменные** `envs/dev/terraform.tfvars`:
```hcl
token          = "your-oauth-token"
cloud_id       = "your-cloud-id"
folder_id      = "your-folder-id"
zone           = "ru-central1-d"
subnet_cidr    = "10.0.0.0/24"
ssh_port       = 22
image_id       = "ubuntu-image-id"
ssh_public_key = "ssh-ed25519 ..."

vms = {
  admin = {
    cores = 2, memory = 2, disk_size = 20
    core_fraction = 20, preemptible = false
    ip_address = "10.0.0.100", hostname = "admin"
    nat = true, role = "jump-host"
  }
  vm-1 = {
    cores = 2, memory = 2, disk_size = 20
    core_fraction = 50, preemptible = false
    ip_address = "10.0.0.101", hostname = "vm-1"
    nat = false, role = "control-plane"
  }
  # vm-2, vm-3 — аналогично с role = "worker"
}
```

**3. Инициализировать и применить:**
```bash
cd envs/dev
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## Архитектура
```
Internet → NAT Gateway → Subnet (<subnet_cidr>)
                            ├── admin  (jump host, nat=true)
                            ├── vm-1   (control-plane)
                            ├── vm-2   (worker)
                            └── vm-3   (worker)
```

## Подключение к VM
```
# ~/.ssh/config
Host admin
  HostName <admin_external_ip>
  User root
  Port <ssh_port>
  IdentityFile ~/.ssh/yc-dev

Host vm-1
  HostName <vm-1_internal_ip>
  User root
  ProxyJump admin
  IdentityFile ~/.ssh/yc-dev

# vm-2, vm-3 — аналогично
```

## Важно
- `backend.hcl` и `*.tfvars` — **не коммитить** (секреты)
- `.terraform.lock.hcl` — **коммитить** (фиксирует версии провайдеров)
- State хранится в Yandex Object Storage
