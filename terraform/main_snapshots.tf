
#Создаем расписание создания snapshot дисков всех машин

resource "yandex_compute_snapshot_schedule" "snapshot_schedule" {
  name           = "snapshot-schedule"
  description    = "Ежедневные снимки. Срок хранения снимков 7 дней"

  schedule_policy {
    expression = "10 0 ? * *"
  }

  retention_period = "168h"

  snapshot_spec {
    description = "retention-snapshot"

  }

disk_ids = ["${yandex_compute_disk.disk_web-a.id}", "${yandex_compute_disk.disk_web-b.id}", "${yandex_compute_disk.disk_elastic.id}", "${yandex_compute_disk.disk_kibana.id}", "${yandex_compute_disk.disk_prometheus.id}", "${yandex_compute_disk.disk_grafana.id}"]
  
  depends_on = [
     yandex_compute_instance.web-a,
     yandex_compute_instance.web-b,
     yandex_compute_instance.elastic-pc,
     yandex_compute_instance.kibana-pc,
     yandex_compute_instance.prometheus-pc,
     yandex_compute_instance.grafana-pc,
  ]
}