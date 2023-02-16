# TODO: Move the other service user config here, when we don't use cloudrun anymore
# Set monitoring perms on the node service user
resource "google_project_iam_member" "inna_monitoring_writer" {
  project = var.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.inna.email}"
}

# Set monitoring perms on the node service user
resource "google_project_iam_member" "inna_monitoring_viewer" {
  project = var.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.inna.email}"
}

# Allow cluster user to pull gcr images
resource "google_storage_bucket_iam_member" "inna_gcr_read" {
  bucket = "eu.artifacts.${var.project}.appspot.com"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.inna.email}"
}

resource "google_container_cluster" "cluster" {
  name        = "inna"
  description = "Innaculator"

  project  = var.project
  location = var.region
}

resource "google_container_node_pool" "main" {
  name    = "inna-main"
  cluster = google_container_cluster.cluster.name

  project  = var.project
  location = var.region

  node_locations = [
    "${var.region}-c",
    "${var.region}-d",
  ]

  initial_node_count = 1

  node_config {
    # Reuse cloudrun invoker user, until we can move to only k8n
    service_account = google_service_account.inna.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/cloudkms",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      pool = "main"
    }
  }
}

# Configure Cloud NAT
# Since we need to pull images from sources other than GCR
# https://stackoverflow.com/questions/57664657/access-non-gcr-public-container-registry-from-private-gke-cluster

resource "google_compute_router" "nat" {
  name    = "default-nat-router"
  network = google_compute_network.vpc.self_link
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "default-nat"
  nat_ip_allocate_option             = "AUTO_ONLY"
  router                             = google_compute_router.nat.name
  region                             = google_compute_router.nat.region
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Cert Manager
# This is used in order to use lets encrypt' certificates and keep them up to for all the k8s microservices
# Certificate and the Issuer resources are defined in the inna repo, as they are namespace-specific
# ----------------------------------------------------

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.id

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "google_service_account" "cert_manager" {
  project      = var.project
  account_id   = "cert-manager"
  display_name = "Certificate Manager"
}

resource "google_project_iam_member" "cert_manager_admin_dns" {
  project = var.project
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.cert_manager.email}"
}


