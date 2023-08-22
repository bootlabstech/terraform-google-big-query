locals {
  tables             = { for table in var.tables : table["table_id"] => table }
  views              = { for view in var.views : view["view_id"] => view }
  materialized_views = { for mat_view in var.materialized_views : mat_view["view_id"] => mat_view }

  iam_to_primitive = {
    "roles/bigquery.dataOwner" : "OWNER"
    "roles/bigquery.dataEditor" : "WRITER"
    "roles/bigquery.dataViewer" : "READER"
  }
}
resource "google_bigquery_dataset" "dataset" {

  dataset_id                      = var.dataset_id
  description                     = var.description
  friendly_name                   = var.friendly_name
  labels                          = var.labels
  location                        = var.location
  project                         = var.project_id
  delete_contents_on_destroy      = var.delete_contents_on_destroy
  default_table_expiration_ms     = var.default_table_expiration_ms
  default_partition_expiration_ms = var.default_partition_expiration_ms
  default_encryption_configuration {
   kms_key_name = var.kms_key_name
   }
}

resource "google_bigquery_dataset_access" "access" {

  dataset_id = var.dataset_id
  project    = var.project_id

  view {
    dataset_id = var.dataset_id
    project_id = var.project_id
    table_id   = var.table_id
  }
  depends_on = [ google_bigquery_dataset.dataset ]
}

resource "google_bigquery_table" "materialized_view" {
  for_each            = local.materialized_views
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  friendly_name       = each.key
  table_id            = each.key
  description         = each.value["description"]
  labels              = each.value["labels"]
  clustering          = each.value["clustering"]
  expiration_time     = each.value["expiration_time"]
  project             = var.project_id
  deletion_protection = false

  dynamic "time_partitioning" {
    for_each = each.value["time_partitioning"] != null ? [each.value["time_partitioning"]] : []
    content {
      type                     = time_partitioning.value["type"]
      expiration_ms            = time_partitioning.value["expiration_ms"]
      field                    = time_partitioning.value["field"]
      require_partition_filter = time_partitioning.value["require_partition_filter"]
    }
  }

  dynamic "range_partitioning" {
    for_each = each.value["range_partitioning"] != null ? [each.value["range_partitioning"]] : []
    content {
      field = range_partitioning.value["field"]
      range {
        start    = range_partitioning.value["range"].start
        end      = range_partitioning.value["range"].end
        interval = range_partitioning.value["range"].interval
      }
    }
  }

  materialized_view {
    query               = each.value["query"]
    enable_refresh      = each.value["enable_refresh"]
    refresh_interval_ms = each.value["refresh_interval_ms"]
  }

  lifecycle {
    ignore_changes = [
      encryption_configuration # managed by google_bigquery_dataset.main.default_encryption_configuration
    ]
  }
}
