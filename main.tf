resource "google_bigquery_dataset" "dataset" {

  dataset_id                      = var.dataset_id
  description                     = var.description
  friendly_name                   = var.friendly_name
  labels                          = var.labels
  location                        = var.location
  project                         = var.project_id
  delete_contents_on_destroy            = var.delete_contents_on_destroy
  default_table_expiration_ms     = var.default_table_expiration_ms
  default_partition_expiration_ms = var.default_partition_expiration_ms
  # default_encryption_configuration {
  #  kms_key_name = google_kms_crypto_key.crypto_key.id
  #  }
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
 


resource "google_bigquery_table" "table" {

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = var.table_id
  project    = var.project_id

  time_partitioning {
    type = var.type
  }
  depends_on = [ google_bigquery_dataset.dataset ]
}

/*
resource "google_kms_crypto_key" "crypto_key" {
  name     = var.key_name
  key_ring = var.key_ring
}
resource "google_bigquery_routine" "routine" {

  dataset_id        = google_bigquery_dataset.dataset.dataset_id
  routine_id        = var.routine_id
  definition_body   = var.definition_body
  routine_type      = var.routine_type
  language          = var.language
  description       = var.description
  determinism_level = var.determinism_level
  project           = var.project_id
  arguments {
    argument_kind = var.argument_kind
    mode          = var.mode
  }
}
*/
