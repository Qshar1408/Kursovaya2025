#  Курсовая работа на профессии "DevOps-инженер с нуля"

### Грибанов Антон. FOPS-31

Содержание
==========
* [Задача](#Задача)
* [Инфраструктура](#Инфраструктура)
    * [Сайт](#Сайт)
    * [Мониторинг](#Мониторинг)
    * [Логи](#Логи)
    * [Сеть](#Сеть)
    * [Резервное копирование](#Резервное-копирование)
    * [Дополнительно](#Дополнительно)
* [Выполнение работы](#Выполнение-работы)


---------
## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/).

**Примечание**: в курсовой работе используется система мониторинга Prometheus. Вместо Prometheus вы можете использовать Zabbix. Задание для курсовой работы с использованием Zabbix находится по [ссылке](https://github.com/netology-code/fops-sysadm-diplom/blob/diplom-zabbix/README.md).

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**   

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible. 

Параметры виртуальной машины (ВМ) подбирайте по потребностям сервисов, которые будут на ней работать. 

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

## Раздел 1. Сайт

***
#### *Задача № 1: Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.*
***

#### 1. Создаём машины А и B (web-a и web-b). Используем два файла - [main_machine.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/main_machine.tf) (в котором находятся непосредственно параметры для VM), а так же [main_machine_disk.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/main_machine_disk.tf) (в нём указаны образы диска для будущих машин) 

```bash
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
```

##### Скриншот развернутых машин:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_001.png)

***
#### *Задача № 2: Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.*
***

#### 2.1. Используем статичные файлы для сайта. 
#### Папка "nginx" - содержит необходимые данные для разворачивания nginx: [default](https://github.com/Qshar1408/Kursovaya2025/blob/main/web/nginx/default), [nginx.conf](https://github.com/Qshar1408/Kursovaya2025/blob/main/web/nginx/nginx.conf) 
#### Папка "WWW" - содержит статичные файлы для веб-сайтов web-a и web-b, а так же default [index.nginx-debian-web-a.html](https://github.com/Qshar1408/Kursovaya2025/blob/main/web/WWW/index.nginx-debian-web-a.html), [index.nginx-debian-web-b.html](https://github.com/Qshar1408/Kursovaya2025/blob/main/web/WWW/index.nginx-debian-web-b.html), [index.nginx-debian.html](https://github.com/Qshar1408/Kursovaya2025/blob/main/web/WWW/index.nginx-debian.html)

```bash
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
	background-color: #4dff9d;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<h2><i><font color="#ff0000"></font>Kursovaya rabota 2025<br>Gribanov Anton. FOPS-31<br>netology <a href="https://netology.ru/">netology.ru</a><br></font></i></h2>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
<br>
<p><u>IP Address Nginx Server:</u> <b><font size="+2" color="#ff0000"><!--#echo var="SERVER_ADDR"--></font></b></br>
<u>Name Nginx Server:</u> <b><font size="+2" color="#ff0000"><!--#echo var="HOSTNAME"--></font></b></p>
<p><em><center><!--#echo var="DATE_LOCAL"--></center></em></p>

</body>
</html>
```

#### 2.2. С помощью Ansible-playbook устанавливаем на машинах web-a и web-b следующие сервисы: Nginx, Filebeat, Node Exporter 

```bash
ansible-playbook -l web web.yaml -k
```
#### Плейбук для разворачивания [web.yaml](https://github.com/Qshar1408/Kursovaya2025/blob/main/ansible/web.yaml)

##### Скриншот запущенного nginx:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_002.png)

##### Скриншот запущенного Filebeat:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_003.png)

##### Скриншот запущенного Node Exporter:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_004.png)

##### Скриншот запущенного сайта web-a:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_010.png)
##### Скриншот запущенного сайте web-b:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_011.png)

***
#### Задача № 3. *Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.*
***

#### 3. Создаем Target Group посредством Terraform [load_balancer.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/load_balancer.tf)

```bash
#Создаем Target Group

resource "yandex_alb_target_group" "web-target-group" {
  name           = "web-target-group"
  description    = "ALB:Целевая группа"
  target {
    subnet_id    = yandex_vpc_subnet.subnet-1.id
    ip_address   = yandex_compute_instance.web-a.network_interface.0.ip_address
  }

  target {
    subnet_id    = yandex_vpc_subnet.subnet-2.id
    ip_address   = yandex_compute_instance.web-b.network_interface.0.ip_address
  }
  
  depends_on = [
     yandex_compute_instance.web-a,
     yandex_compute_instance.web-b,
  ]
}
```
##### Скриншот созданной Target Group:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_005.png)

***
#### Задача № 4. *Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.*
***

#### 4. Создаем Backend Group посредством Terraform [load_balancer.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/load_balancer.tf)

```bash
#Создаем Backend Group

resource "yandex_alb_backend_group" "my_backend_group" {
  name                     = "my-backend-group"
  description              = "ALB:Группа бэкендов"
  http_backend {
    name                   = "my-backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["${yandex_alb_target_group.web-target-group.id}"]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
```
##### Скриншот созданной Backend Group:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_006.png)

***
#### Задача № 5. *Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.*
***

#### 5. Создаем HTTP router посредством Terraform [load_balancer.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/load_balancer.tf)

```bash
#Создаем HTTP route

resource "yandex_alb_http_router" "my_http_router" {
  name          = "my-http-router"
  description   = "ALB:HTTP роутер"
}

resource "yandex_alb_virtual_host" "my_virtual_host" {
  name                    = "my-virtual-host"
  http_router_id          = "${yandex_alb_http_router.my_http_router.id}"
  route {
    name                  = "project-route"
    http_route {
      http_route_action {
        backend_group_id  = "${yandex_alb_backend_group.my_backend_group.id}"
        timeout           = "60s"
      }
    }
  }
  
  depends_on = [
     yandex_alb_http_router.my_http_router,
     yandex_alb_backend_group.my_backend_group,
  ]
}
```
##### Скриншот созданного HTTP router:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_007.png)

***
#### Задача № 6. *Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.*
***

#### 6. Создаем Application load balancer посредством Terraform [load_balancer.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/load_balancer.tf)

```bash
#Создание балансировщика (Application load balancer)

resource "yandex_alb_load_balancer" "alb-1" {
  name        = "alb-1"
  description = "ALB"
  network_id  = "${yandex_vpc_network.network-1.id}"

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    }
  }

listener {
    name = "mylistener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = "${yandex_alb_http_router.my_http_router.id}"
      }
    }
  }
  
  depends_on = [
     yandex_alb_http_router.my_http_router,
  ]
}
```
##### Скриншот созданного Application load balancer:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_008.png)
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_009.png)

***
#### Задача № 7. *Протестируйте сайт `curl -v <публичный IP балансера>:80`*
***

#### 7.Тест сайта:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_014.png)

##### Скриншот запущенного сайта через балансировщик:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_012.png)
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_013.png)

## Раздел 2. Мониторинг

***
#### Задача № 1. *Создайте ВМ, разверните на ней Prometheus. На каждую ВМ из веб-серверов установите Node Exporter и [Nginx Log Exporter](https://github.com/martin-helmich/prometheus-nginxlog-exporter). Настройте Prometheus на сбор метрик с этих exporter.*
***

#### 1. Создаём VM Prometheus. Используем два файла - [main_machine.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/main_machine.tf) (в котором находятся непосредственно параметры для VM), а так же [main_machine_disk.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/main_machine_disk.tf) (в нём указаны образы диска для будущих машин) 

```bash
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
```

```bash
resource "yandex_compute_disk" "disk_prometheus" {
  name     = "disk-prometheus"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd8gqjo661d83tv5dnv4"
  size     = 6
}
```

#### 1.2. С помощью Ansible-playbook устанавливаем сам Prometheus, а так же Node Exporter и Filebeat

```bash
ansible-playbook -l mons monitoring.yaml -k
```

#### Плейбук для разворачивания [monitoring.yaml](https://github.com/Qshar1408/Kursovaya2025/blob/main/ansible/monitoring.yaml)

##### Скриншот запущенного сервиса Prometheus:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_015.png)

##### Скриншот запущенного сервиса Node-Exporter:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_016.png)

##### Скриншот запущенного сервиса Filebeat:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_017.png)

##### Скриншот запущенного Prometheus (порт 9090):
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_018.png)

##### Скриншот запущенного Prometheus (порт 9100):
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_019.png)

***
#### Задача № 2. *Создайте ВМ, установите туда Grafana. Настройте её на взаимодействие с ранее развернутым Prometheus. Настройте дешборды с отображением метрик, минимальный набор — Utilization, Saturation, Errors для CPU, RAM, диски, сеть, http_response_count_total, http_response_size_bytes. Добавьте необходимые [tresholds](https://grafana.com/docs/grafana/latest/panels/thresholds/) на соответствующие графики.*
***

#### 2.1. Создаём VM Grafana. Используем два файла - [main_machine.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/main_machine.tf) (в котором находятся непосредственно параметры для VM), а так же [main_machine_disk.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/main_machine_disk.tf) (в нём указаны образы диска для будущих машин) 

```bash
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
```

```bash
resource "yandex_compute_disk" "disk_grafana" {
  name     = "disk-grafana"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd8gqjo661d83tv5dnv4"
  size     = 6
}
```

#### 2.1. С помощью Ansible-playbook устанавливаем саму Grafana, а так же Filebeat. В процессе установки подгружаем БД [grafana.db](https://github.com/Qshar1408/Kursovaya2025/blob/main/monitoring/grafana/grafana.db)  с настроенными метриками

```bash
ansible-playbook -l mons monitoring.yaml -k
```

#### Плейбук для разворачивания [monitoring.yaml](https://github.com/Qshar1408/Kursovaya2025/blob/main/ansible/monitoring.yaml)

##### Скриншот запущенного сервиса Grafana:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_020.png)

##### Скриншот запущенного сервиса Filebeat:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_021.png)

##### Скриншот запущенного портала Grafana:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_022.png)

При входе используем логин "admin" и пароль "Grafana123" (при необходимости меняем)

Так же, после авторизации необходимо проверить настройки подключения к Prometheus (т.к. после поднятия машины может поменятся внешний IP-адрес)

##### Скриншот проверки подключения к Prometheus:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_023.png)

##### Скриншот выбора Dashboard-ов:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_024.png)

##### Скриншот настроенных метрик для веб-сайта web-a:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_025.png)

##### Скриншот настроенных метрик для веб-сайта web-b:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_026.png)

##### Скриншот настроенных метрик для веб-сайта Prometheus:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_027.png)


## Раздел 3. Логи

***
#### Задача № 1. *Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.*
***

#### 1.1. Создаём VM Elasticsearch. Используем два файла - [main_machine.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/main_machine.tf) (в котором находятся непосредственно параметры для VM), а так же [main_machine_disk.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/main_machine_disk.tf) (в нём указаны образы диска для будущих машин) 

```bash
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
```

```bash
resource "yandex_compute_disk" "disk_elastic" {
  name     = "disk-elastic"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd8gqjo661d83tv5dnv4"
  size     = 8
}
```

#### 1.2. С помощью Ansible-playbook устанавливаем сам Elasticsearch и Filebeat

```bash
ansible-playbook -l mons logs.yaml -k
```

#### Плейбук для разворачивания [logs.yaml](https://github.com/Qshar1408/Kursovaya2025/blob/main/ansible/logs.yaml)

##### Скриншот запущенного сервиса Elasticsearch:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_028.png)

##### Скриншот запущенного сервиса Filebeat:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_029.png)

##### Скриншот запущенного портала Elasticsearch (Логин: elastic; Пароль: 1qaz@WSX):
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_030.png)

***
#### Задача № 2. *Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.*
***

#### 2.1. Создаём VM Kibana. Используем два файла - [main_machine.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/main_machine.tf) (в котором находятся непосредственно параметры для VM), а так же [main_machine_disk.tf](https://github.com/Qshar1408/Kursovaya2025/blob/main/terraform/main_machine_disk.tf) (в нём указаны образы диска для будущих машин) 

```bash
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
```

```bash
resource "yandex_compute_disk" "disk_kibana" {
  name     = "disk-kibana"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd8gqjo661d83tv5dnv4"
  size     = 8
}
```

#### 2.2. С помощью Ansible-playbook устанавливаем саму Kibana и Filebeat

```bash
ansible-playbook -l mons logs.yaml -k
```
#### Плейбук для разворачивания [logs.yaml](https://github.com/Qshar1408/Kursovaya2025/blob/main/ansible/logs.yaml)

##### Скриншот запущенного сервиса Kibana:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_031.png)

##### Скриншот запущенного сервиса Filebeat:
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_032.png)

##### Скриншот запущенного портала Kibana (Логин: elastic; Пароль: 1qaz@WSX):
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_033.png)
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_034.png)

##### Скриншот настройки индексов Filebeat
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_035.png)
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_036.png)

##### Скриншот логов с сервера web-a
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_037.png)

##### Скриншот логов с сервера web-b
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_038.png)

##### Скриншот логов с сервера Prometheus
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_039.png)

##### Скриншот логов с сервера Grafana
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_040.png)

##### Скриншот логов с сервера Elasticsearch
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_041.png)

##### Скриншот логов с сервера Kibana
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_042.png)

##### Скриншот логов Dashboard
![Kurs2025](https://github.com/Qshar1408/Kursovaya2025/blob/main/img/kurs2025_043.png)



### Сеть
Разверните один VPC. Сервера web, Prometheus, Elasticsearch поместите в приватные подсети. Сервера Grafana, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

### Дополнительно
Не входит в минимальные требования. 

1. Для Prometheus можно реализовать альтернативный способ хранения данных — в базе данных PpostgreSQL. Используйте [Yandex Managed Service for PostgreSQL](https://cloud.yandex.com/en-ru/services/managed-postgresql). Разверните кластер из двух нод с автоматическим failover. Воспользуйтесь адаптером с https://github.com/CrunchyData/postgresql-prometheus-adapter для настройки отправки данных из Prometheus в новую БД.
2. Вместо конкретных ВМ, которые входят в target group, можно создать [Instance Group](https://cloud.yandex.com/en/docs/compute/concepts/instance-groups/), для которой настройте следующие правила автоматического горизонтального масштабирования: минимальное количество ВМ на зону — 1, максимальный размер группы — 3.
3. Можно добавить в Grafana оповещения с помощью Grafana alerts. Как вариант, можно также установить Alertmanager в ВМ к Prometheus, настроить оповещения через него.
4. В Elasticsearch добавьте мониторинг логов самого себя, Kibana, Prometheus, Grafana через filebeat. Можно использовать logstash тоже.
5. Воспользуйтесь Yandex Certificate Manager, выпустите сертификат для сайта, если есть доменное имя. Перенастройте работу балансера на HTTPS, при этом нацелен он будет на HTTP веб-серверов.


