#Создаем группу безопасности для веб-серверов (web-a, web-b)

resource "yandex_vpc_security_group" "web-sg" {
  name                 = "web-sg"
  description          = "SG для WEB"
  network_id           = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol           = "TCP"
    description        = "in web server"
    v4_cidr_blocks     = ["0.0.0.0/0"]
    port               = 80
  }

  ingress {
    protocol           = "TCP"
    description        = "from internal Grafana to SSH"
    v4_cidr_blocks     = ["${yandex_compute_instance.grafana-pc.network_interface[0].ip_address}/32"]
    port               = 22
  }

  ingress {
    protocol           = "TCP"
    description        = "from internal to metrics node-exporter"
    v4_cidr_blocks     = ["192.168.0.0/24"]
    port               = 9100
  }

  ingress {
    protocol           = "TCP"
    description        = "from internal to metrics nginxlog-exporter"
    v4_cidr_blocks     = ["192.168.0.0/24"]
    port               = 4040
  }

  ingress {
    protocol           = "ANY"
    description        = "loadbalancer healthchecks"
    predefined_target  = "loadbalancer_healthchecks"
  }


  egress {
    protocol           = "TCP"
    description        = "to internal Elasticsearch from Filebeat"
    v4_cidr_blocks     = ["192.168.0.0/24"]
    port               = 9200
  }

  
  depends_on = [
     yandex_compute_instance.grafana-pc,
  ]
}

#Создаем группу безопасности для Prometheus

resource "yandex_vpc_security_group" "prometheus-sg" {
  name                 = "prometheus-sg"
  description          = "SG для Prometheus"
  network_id           = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol           = "TCP"
    description        = "from internal Grafana to SSH"
    v4_cidr_blocks     = ["${yandex_compute_instance.grafana-pc.network_interface[0].ip_address}/32"]
    port               = 22
  }

  ingress {
    protocol           = "TCP"
    description        = "from internal Grafana to Prometheus"
    v4_cidr_blocks     = ["192.168.0.0/24"]
    port               = 9090
  }


  egress {
    protocol           = "TCP"
    description        = "to internal Node Exporter from Prometheus"
    v4_cidr_blocks     = ["192.168.10.0/24", "192.168.11.0/24"]
    port               = 9100
  }

  egress {
    protocol           = "TCP"
    description        = "to internal Nginx Log Exporter from Prometheus"
    v4_cidr_blocks     = ["192.168.10.0/24", "192.168.11.0/24"]
    port               = 4040
  }
  
  egress {
    protocol           = "TCP"
    description        = "to internal Elasticsearch from Filebeat"
    v4_cidr_blocks     = ["192.168.0.0/24"]
    port               = 9200
  }
  
  depends_on = [
     yandex_compute_instance.grafana-pc,
  ]
}

#Создаем группу безопасности для Grafana

resource "yandex_vpc_security_group" "grafana-sg" {
  name                 = "grafana-sg"
  description          = "SG для Grafana + Bastion Host"
  network_id           = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol           = "TCP"
    description        = "in Grafana SSH"
    v4_cidr_blocks     = ["0.0.0.0/0"]
    port               = 22
  }

  ingress {
    protocol           = "TCP"
    description        = "in Grafana GUI"
    v4_cidr_blocks     = ["0.0.0.0/0"]
    port               = 3000
  }


  egress {
    protocol           = "TCP"
    description        = "to internal Prometheus from Grafana"
    v4_cidr_blocks     = ["192.168.0.0/24"]
    port               = 9090
  }

  egress {
    protocol           = "TCP"
    description        = "to internal VM SSH from Grafana"
    v4_cidr_blocks     = ["192.168.10.0/24", "192.168.11.0/24", "192.168.12.0/24"]
    port               = 22
  }
  
  egress {
    protocol           = "TCP"
    description        = "to internal Elasticsearch from Filebeat"
    v4_cidr_blocks     = ["192.168.0.0/24"]
    port               = 9200
  }
}

#Создаем группу безопасности для Elasticsearch

resource "yandex_vpc_security_group" "elastic-sg" {
  name                 = "elastic-sg"
  description          = "SG для Elasticsearch"
  network_id           = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol           = "TCP"
    description        = "from internal Grafana to SSH"
    v4_cidr_blocks     = ["${yandex_compute_instance.grafana-pc.network_interface[0].ip_address}/32"]
    port               = 22
  }


  ingress {
    protocol           = "TCP"
    description        = "from internal to Elasticsearc"
    v4_cidr_blocks     = ["192.168.10.0/24", "192.168.11.0/24"]
    port               = 9200
  }


  egress {
    protocol           = "TCP"
    description        = "to internal Kibana from Elasticsearch"
    v4_cidr_blocks     = ["192.168.10.0/24", "192.168.11.0/24"]
    port               = 5601
  }
  
  depends_on = [
     yandex_compute_instance.grafana-pc,
  ]
}

#Создаем группу безопасности для Kibana

resource "yandex_vpc_security_group" "kibana-sg" {
  name                 = "kibana-sg"
  description          = "SG для Kibana"
  network_id           = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol           = "TCP"
    description        = "from internal Grafana to SSH"
    v4_cidr_blocks     = ["${yandex_compute_instance.grafana-pc.network_interface[0].ip_address}/32"]
    port               = 22
  }

  ingress {
    protocol           = "TCP"
    description        = "in Kibana GUI"
    v4_cidr_blocks     = ["0.0.0.0/0"]
    port               = 5601
  }


  egress {
    protocol           = "TCP"
    description        = "to internal Elasticsearch from Kibana"
    v4_cidr_blocks     = ["192.168.10.0/24", "192.168.11.0/24"]
    port               = 9200
  }
  
  egress {
    protocol           = "TCP"
    description        = "to internal Elasticsearch from Filebeat"
    v4_cidr_blocks     = ["192.168.0.0/24"]
    port               = 9200
  }
  
  depends_on = [
     yandex_compute_instance.grafana-pc,
  ]
}