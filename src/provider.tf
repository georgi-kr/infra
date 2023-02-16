provider "google" {
  region  = var.region
  project = var.project
}

provider "google-beta" {
  project = var.project
  region  = var.region
}

data "google_project" "project" {}

data "google_client_config" "provider" {}

provider "kubernetes" {
  host                   = google_container_cluster.cluster.endpoint
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)
}

# TODO For certificates
provider "helm" {
  kubernetes {
    host                   = google_container_cluster.cluster.endpoint
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)
  }
}
