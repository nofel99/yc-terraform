# Использую S3 яндекс бакет для хранения
# состояния tfstate. В этом бэкенде активирована версионность
# т.е. после каждого изменения tfstate сохраняется и можно откатиться назад


terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    bucket = "tfstate-britva"
    region = "ru-central1"
    key    = "terraform/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true

    # Чувствительные данные передаются через backend.hcl:
    # terraform init -backend-config=backend.hcl
  }
}
