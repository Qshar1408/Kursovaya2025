
#Создаем файл inventory для ansible
resource "local_file" "inventory" {
  content = <<-XYZ
  [logs]
  elastic-pc ansible_host=${yandex_compute_instance.elastic-pc.network_interface.0.nat_ip_address} ansible_connection=ssh ansible_ssh_user=qshar
  kibana-pc ansible_host=${yandex_compute_instance.kibana-pc.network_interface.0.nat_ip_address} ansible_connection=ssh ansible_ssh_user=qshar

  [web]
  web-a ansible_host=${yandex_compute_instance.web-a.network_interface.0.nat_ip_address} ansible_connection=ssh ansible_ssh_user=qshar
  web-b ansible_host=${yandex_compute_instance.web-b.network_interface.0.nat_ip_address} ansible_connection=ssh ansible_ssh_user=qshar
  
  [mons]
  prometheus-pc ansible_host=${yandex_compute_instance.prometheus-pc.network_interface.0.nat_ip_address} ansible_connection=ssh ansible_ssh_user=qshar
  grafana-pc ansible_host=${yandex_compute_instance.grafana-pc.network_interface.0.nat_ip_address} ansible_connection=ssh ansible_ssh_user=qshar

  XYZ
  filename = "/home/qshar/kurs2025/ansible/hosts"
}



output "internal_ip_address_web-a" {
  value = yandex_compute_instance.web-a.network_interface.0.ip_address
}

output "external_ip_address_web-a" {
  value = yandex_compute_instance.web-a.network_interface.0.nat_ip_address
}

output "internal_ip_address_web-b" {
  value = yandex_compute_instance.web-b.network_interface.0.ip_address
}

output "external_ip_address_web-b" {
  value = yandex_compute_instance.web-b.network_interface.0.nat_ip_address
}

