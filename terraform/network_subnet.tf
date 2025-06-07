#Создаем облачную сеть
resource "yandex_vpc_network" "network-1" {
  name = "network-1"
}

#Создаем подсеть  в зоне А
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet-1"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
  zone           = "ru-central1-a"
}

#Создаем подсеть  в зоне В
resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet-2"
  v4_cidr_blocks = ["192.168.11.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
  zone           = "ru-central1-b"
}
