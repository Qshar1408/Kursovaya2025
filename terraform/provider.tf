terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  cloud_id  = "b1g1ap2fp1jt638alsl9"
  folder_id = "b1g3sfourkjnlhsdmlut"
  service_account_key_file = file("/home/qshar/kurs2025/.authorized_key.json")
}
