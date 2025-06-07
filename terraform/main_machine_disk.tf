resource "yandex_compute_disk" "disk_web-a" {
  name     = "disk_web-a"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd8gqjo661d83tv5dnv4"
  size     = 3
}


resource "yandex_compute_disk" "disk_web-b" {
  name     = "disk-web-b"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  image_id = "fd8gqjo661d83tv5dnv4"
  size     = 3
}


resource "yandex_compute_disk" "disk_elastic" {
  name     = "disk-elastic"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd8gqjo661d83tv5dnv4"
  size     = 8
}


resource "yandex_compute_disk" "disk_kibana" {
  name     = "disk-kibana"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd8gqjo661d83tv5dnv4"
  size     = 8
}


resource "yandex_compute_disk" "disk_prometheus" {
  name     = "disk-prometheus"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd8gqjo661d83tv5dnv4"
  size     = 6
}


resource "yandex_compute_disk" "disk_grafana" {
  name     = "disk-grafana"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd8gqjo661d83tv5dnv4"
  size     = 6
}