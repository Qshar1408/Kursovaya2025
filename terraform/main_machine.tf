#Создаем машину А

resource "yandex_compute_instance" "web-a"{
  name            = "web-a"
  platform_id     = "standard-v1"
  zone      = "ru-central1-a"
  allow_stopping_for_update = true
  hostname = "web-a"

  resources {
    cores         = 2
    core_fraction = 5
    memory        = 1
  }

    boot_disk {
    disk_id     = "${yandex_compute_disk.disk_web-a.id}"
  }
  
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
      }

   metadata = {
    ssh-keys    = "qshar:${file("~/.ssh/id_rsa2025.pub")}"
    user-data   = "#cloud-config\ndatasource:\n Ec2:\n  strict_id: false\nssh_pwauth: no\nusers:\n- name: qshar\n  sudo: ALL=(ALL) NOPASSWD:ALL\n  shell: /bin/bash\n  ssh_authorized_keys:\n  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItN3dEKvFKOGoTEQGZbdp7Gy9gXeKZK9T85zlyaM63T qshar@qsharpc03"
  }

  scheduling_policy {
    preemptible = true
  }
}

#Создаем машину В 

resource "yandex_compute_instance" "web-b"{
  name            = "web-b"
  platform_id     = "standard-v1"
  zone      = "ru-central1-b"
  allow_stopping_for_update = true
  hostname = "web-b"

  resources {
    cores         = 2
    core_fraction = 5
    memory        = 1
  }

     boot_disk {
    disk_id     = "${yandex_compute_disk.disk_web-b.id}"
  }
  
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    nat       = true
    
  }

 metadata = {
    ssh-keys    = "qshar:${file("~/.ssh/id_rsa2025.pub")}"
    user-data   = "#cloud-config\ndatasource:\n Ec2:\n  strict_id: false\nssh_pwauth: no\nusers:\n- name: qshar\n  sudo: ALL=(ALL) NOPASSWD:ALL\n  shell: /bin/bash\n  ssh_authorized_keys:\n  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItN3dEKvFKOGoTEQGZbdp7Gy9gXeKZK9T85zlyaM63T qshar@qsharpc03"
  }

  scheduling_policy {
    preemptible = true
  }
}

#Создаем машину Elastic

resource "yandex_compute_instance" "elastic-pc" {
  name                      = "elastic-pc"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"
  hostname                  = "elastic-pc"

  resources {
    cores          = 2
    memory         = 4
    core_fraction  = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk_elastic.id}"
  }
  
  network_interface {
    subnet_id   = "${yandex_vpc_subnet.subnet-1.id}"
    nat         = true
  }
  
  scheduling_policy {
    preemptible = true
  }

metadata = {
    ssh-keys    = "qshar:${file("~/.ssh/id_rsa2025.pub")}"
    user-data   = "#cloud-config\ndatasource:\n Ec2:\n  strict_id: false\nssh_pwauth: no\nusers:\n- name: qshar\n  sudo: ALL=(ALL) NOPASSWD:ALL\n  shell: /bin/bash\n  ssh_authorized_keys:\n  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItN3dEKvFKOGoTEQGZbdp7Gy9gXeKZK9T85zlyaM63T qshar@qsharpc03"
  }

}

#Создаем машину Kibana

resource "yandex_compute_instance" "kibana-pc" {
  name                      = "kibana-pc"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"
  hostname                  = "kibana-pc"

  resources {
    cores          = 2
    memory         = 4
    core_fraction  = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk_kibana.id}"
  }
  
  network_interface {
    subnet_id   = "${yandex_vpc_subnet.subnet-1.id}"
    nat         = true
  }
  
  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys    = "qshar:${file("~/.ssh/id_rsa2025.pub")}"
    user-data   = "#cloud-config\ndatasource:\n Ec2:\n  strict_id: false\nssh_pwauth: no\nusers:\n- name: qshar\n  sudo: ALL=(ALL) NOPASSWD:ALL\n  shell: /bin/bash\n  ssh_authorized_keys:\n  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItN3dEKvFKOGoTEQGZbdp7Gy9gXeKZK9T85zlyaM63T qshar@qsharpc03"
  }

}

#Создаем машину Prometheus

resource "yandex_compute_instance" "prometheus-pc" {
  name                      = "prometheus-pc"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"
  hostname                  = "prometheus-pc"

  resources {
    cores          = 2
    memory         = 2
    core_fraction  = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk_prometheus.id}"
  }
  
  network_interface {
    subnet_id   = "${yandex_vpc_subnet.subnet-1.id}"
    nat         = true
  }
  
  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys    = "qshar:${file("~/.ssh/id_rsa2025.pub")}"
    user-data   = "#cloud-config\ndatasource:\n Ec2:\n  strict_id: false\nssh_pwauth: no\nusers:\n- name: qshar\n  sudo: ALL=(ALL) NOPASSWD:ALL\n  shell: /bin/bash\n  ssh_authorized_keys:\n  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItN3dEKvFKOGoTEQGZbdp7Gy9gXeKZK9T85zlyaM63T qshar@qsharpc03"
  }

}

#Создаем машину Grafana

resource "yandex_compute_instance" "grafana-pc" {
  name                      = "grafana-pc"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"
  hostname                  = "grafana-pc"

  resources {
    cores          = 2
    memory         = 2
    core_fraction  = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk_grafana.id}"
  }
  
  
   network_interface {
    subnet_id   = "${yandex_vpc_subnet.subnet-1.id}"
    nat         = true
  }
  
  scheduling_policy {
    preemptible = true
  }
metadata = {
    ssh-keys    = "qshar:${file("~/.ssh/id_rsa2025.pub")}"
    user-data   = "#cloud-config\ndatasource:\n Ec2:\n  strict_id: false\nssh_pwauth: no\nusers:\n- name: qshar\n  sudo: ALL=(ALL) NOPASSWD:ALL\n  shell: /bin/bash\n  ssh_authorized_keys:\n  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItN3dEKvFKOGoTEQGZbdp7Gy9gXeKZK9T85zlyaM63T qshar@qsharpc03"
  }
}
