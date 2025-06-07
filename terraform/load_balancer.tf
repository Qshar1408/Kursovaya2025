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
  
  depends_on = [
     yandex_alb_target_group.web-target-group,
  ]
}

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