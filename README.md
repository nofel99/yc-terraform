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

```bash
# 1. Создать секреты backend
cat > envs/dev/backend.hcl << EOF
bucket     = "your-bucket"
access_key = "your-key"
secret_key = "your-secret"
EOF

# 2. Заполнить переменные
# отредактировать envs/dev/terraform.tfvars

# 3. Инициализировать и применить
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
# аналогично для vm-2, vm-3

```
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
```

## Важно

- `backend.hcl` и `*.tfvars` — **не коммитить** (секреты)
- `.terraform.lock.hcl` — **коммитить** (фиксирует версии провайдеров)
- State хранится в Yandex Object Storage
