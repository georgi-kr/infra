# Database
# -----------------------------------------------------------------------------

resource "random_id" "inna_db_instance" {
  byte_length = 8
  prefix      = "inna-"
}

resource "google_sql_database_instance" "inna_db_instance" {
  name             = random_id.inna_db_instance.hex
  database_version = "POSTGRES_13"
  project          = var.project
  region           = var.region
  depends_on       = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier              = var.inna_db.tier
    disk_autoresize   = true
    availability_type = "REGIONAL"

    database_flags {
      name  = "log_min_duration_statement"
      value = var.inna_db.slow_query_log
    }

    database_flags {
      name  = "log_statement"
      value = "none"
    }

    backup_configuration {
      location   = "us"
      enabled    = true
      start_time = "02:00"
    }

    maintenance_window {
      day          = 6
      update_track = "stable"
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.vpc.id
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = false
    }
  }
}

resource "random_password" "inna_db_sql_user_password" {
  count  = length(var.berglas)
  length  = 16
  special = false
}
resource "google_sql_user" "inna_db_sql_user" {
  count    = length(var.berglas)
  name     = var.berglas[count.index].env == null ? "inna" : "inna-${var.berglas[count.index].env}"
  instance = google_sql_database_instance.inna_db_instance.name
  password = random_password.inna_db_sql_user_password[count.index].result
}

resource "berglas_secret" "inna_db_password" {
  count     = length(var.berglas)
  bucket    = var.berglas[count.index].bucket
  key       = var.berglas[count.index].key
  name      = "inna_db_password"
  plaintext = random_password.inna_db_sql_user_password[count.index].result
}

## TODO GENERATE USERS FOR GITHUB ACTIONS CI/CD example below for Circle CI
# # CircleCI User
# # -----------------------------------------------------------------------------

# # A service user user for deployment from CircleCI
# # Needs to create / destroy buckets, create / destroy sql databases and deploy to cloudrun

# resource "google_service_account" "inna_circleci" {
#   project      = var.project
#   account_id   = "inna-circleci"
#   display_name = "inna user for deployment from CircleCI"
# }

# resource "google_project_iam_member" "inna_circleci_storage_admin" {
#   project = var.project
#   role    = "roles/storage.admin"
#   member  = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# resource "google_project_iam_member" "inna_circleci_storage_viewer" {
#   project = var.project
#   role    = "roles/storage.objectViewer"
#   member  = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# resource "google_project_iam_member" "inna_circleci_k8s_admin" {
#   project = var.project
#   role    = "roles/container.admin"
#   member  = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# resource "google_project_iam_member" "inna_circleci_k8s_service_user" {
#   project = var.project
#   role    = "roles/iam.serviceAccountUser"
#   member  = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# resource "google_project_iam_member" "inna_circleci_view_cluster" {
#   project = var.project
#   role    = "roles/compute.networkViewer"
#   member  = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# resource "google_project_iam_member" "inna_circleci_read_dns" {
#   project = var.project
#   role    = "roles/dns.reader"
#   member  = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# resource "google_project_iam_member" "inna_circleci_sql" {
#   project = var.project
#   role    = "roles/cloudsql.editor"
#   member  = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# resource "google_project_iam_member" "inna_circleci_service_user_admin" {
#   project = var.project
#   role    = "roles/iam.serviceAccountAdmin"
#   member  = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# resource "google_project_iam_member" "inna_circleci_admin_dns" {
#   project = var.project
#   role    = "roles/dns.admin"
#   member  = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# resource "google_project_iam_member" "inna_circleci_key_creator" {
#   project = var.project
#   role    = "roles/iam.serviceAccountKeyAdmin"
#   member  = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# resource "google_service_account_iam_member" "admin-account-iam" {
#   service_account_id = google_service_account.inna.name
#   role               = "roles/iam.serviceAccountUser"
#   member             = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# resource "google_project_iam_member" "inna_circleci_compute_admin_public_ip" {
#   project = var.project
#   role    = "roles/compute.publicIpAdmin"
#   member  = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# # We manually add the permissions for the secrets bucket that a `berglas grant` call would have done
# # https://github.com/GoogleCloudPlatform/berglas#cloud-storage-storage-1
# resource "google_storage_bucket_iam_member" "inna_circleci_berglas" {
#   count  = length(var.berglas)
#   bucket = var.berglas[count.index].bucket
#   role   = "roles/storage.objectViewer"
#   member = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# # We manually add the permissions for berglas kms key that a `berglas grant` call would have done
# # https://github.com/GoogleCloudPlatform/berglas#cloud-storage-storage-1
# resource "google_kms_crypto_key_iam_member" "inna_circleci_berglas" {
#   count         = length(var.berglas)
#   crypto_key_id = var.berglas[count.index].key
#   role          = "roles/cloudkms.cryptoKeyDecrypter"
#   member        = "serviceAccount:${google_service_account.inna_circleci.email}"
# }

# resource "google_service_account_key" "inna_circleci_key" {
#   service_account_id = google_service_account.inna_circleci.name
# }

# resource "berglas_secret" "inna_circleci" {
#   count     = length(var.berglas)
#   bucket    = var.berglas[count.index].bucket
#   key       = var.berglas[count.index].key
#   name      = "inna_circleci_domain_credentials"
#   plaintext = base64decode(google_service_account_key.inna_circleci_key.private_key)
# }

# Execution Service Account
# -----------------------------------------------------------------------------

# A service account for cloudrun service inna. must have access to berglas secrets
resource "google_service_account" "inna" {
  project      = var.project
  account_id   = "inna"
  display_name = "A service account for cloudrun service inna"
}

resource "google_project_iam_member" "inna_service_log" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.inna.email}"
}

# We manually add the permissions for the secrets bucket that a `berglas grant` call would have done
# https://github.com/GoogleCloudPlatform/berglas#cloud-storage-storage-1
resource "google_storage_bucket_iam_member" "inna_berglas" {
  count  = length(var.berglas)
  bucket = var.berglas[count.index].bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.inna.email}"
}

# We manually add the permissions for berglas kms key that a `berglas grant` call would have done
# https://github.com/GoogleCloudPlatform/berglas#cloud-storage-storage-1
resource "google_kms_crypto_key_iam_member" "inna_berglas" {
  count         = length(var.berglas)
  crypto_key_id = var.berglas[count.index].key
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = "serviceAccount:${google_service_account.inna.email}"
}

# For connecting to sql
# https://cloud.google.com/sql/docs/postgres/connect-run#configuring
resource "google_project_iam_member" "inna_cloudsql_role" {
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.inna.email}"
}

# Domain Credentials User
# -----------------------------------------------------------------------------

# A servive user created specifically to be able to pull google groups for an innaculator account
resource "google_service_account" "inna_oauth2" {
  project      = var.project
  account_id   = "inna-oauth2"
  display_name = "inna user for OAuth and retrieving google groups"
}

# Create a json key for the inna_oauth2 service user. This is the domain credentials.
resource "google_service_account_key" "inna_oauth2_key" {
  service_account_id = google_service_account.inna_oauth2.name
}

resource "berglas_secret" "inna_oauth2_domain_credentials" {
  count     = length(var.berglas)
  bucket    = var.berglas[count.index].bucket
  key       = var.berglas[count.index].key
  name      = "inna_oauth2_domain_credentials"
  plaintext = base64decode(google_service_account_key.inna_oauth2_key.private_key)
}


# Service Specific Secrets (API)
# -----------------------------------------------------------------------------

resource "random_password" "inna_secret" {
  count   = length(var.berglas)
  length  = 16
  special = false
}

resource "berglas_secret" "inna_secret" {
  count  = length(var.berglas)
  bucket = var.berglas[count.index].bucket
  key    = var.berglas[count.index].key
  name   = "inna_secret"

  plaintext = random_password.inna_secret[count.index].result
}

# Service Specific Secrets (Client)
# -----------------------------------------------------------------------------

resource "random_password" "inna_client_secret" {
  count   = length(var.berglas)
  length  = 32
  special = true
}

resource "berglas_secret" "inna_client_secret" {
  count  = length(var.berglas)
  bucket = var.berglas[count.index].bucket
  key    = var.berglas[count.index].key
  name   = "inna_client_secret"

  plaintext = random_password.inna_client_secret[count.index].result
}

# Storage to keep files of all kinds that can be accesed in the api.
# ----------------------------------------------------
resource "google_storage_bucket" "datasource_storage" {
  name     = "${var.project}-datasource-storage"
  location = "EU"
}

resource "google_storage_bucket_iam_member" "inna_storage" {
  bucket = google_storage_bucket.datasource_storage.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:inna@${var.project}.iam.gserviceaccount.com"
}
