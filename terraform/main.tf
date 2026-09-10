# VPC NETWORK 

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

# SUBNET WITH SECONDARY IP RANGES FOR GKE PODS AND SERVICES

resource "google_compute_subnetwork" "subnet" {
  name                     = var.subnet_name
  ip_cidr_range            = var.subnet_ip_range
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_ip_range
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_ip_range
  }
}

# CLOUD ROUTER FOR PRIVATE GKE NODE INTERNET EGRESS

resource "google_compute_router" "nat_router" {
  name    = "${var.vpc_name}-nat-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

# CLOUD NAT FOR PRIVATE GKE NODES

resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# PRIVATE GKE CLUSTER WITH WORKLOAD IDENTITY FEDERATION

resource "google_container_cluster" "primary" {
  name                     = var.gke_cluster_name
  location                 = var.region
  network                  = google_compute_network.vpc.id
  subnetwork               = google_compute_subnetwork.subnet.id
  remove_default_node_pool = true
  initial_node_count       = 1
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }
}

# GKE AUTOSCALING NODE POOL 

resource "google_container_node_pool" "primary_nodes" {
  name       = var.primary_node_pool_name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    labels = {
      "envvironment" = "dev"
    }
  }
}

# GCP SERVICE ACCOUNT FOR WORKLOAD IDENTITY

resource "google_service_account" "gke_sa" {
  account_id   = "gke-workload-identity-sa"
  display_name = "GKE Workload Identity Service Account"
}

# GRANT GCS VIEWER ROLE TO SERVICE ACCOUNT

resource "google_project_iam_member" "sa_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

# BIND GKE KSA TO GSA  UING WORK LOAD IDENTITY

resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.gke_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[production/backend-ksa]"
}

# ARTIFACT REGISTRY REPOSITORY FOR CONTAINER IMAGES

resource "google_artifact_registry_repository" "repo" {
  provider      = google
  location      = var.region
  repository_id = var.repo_id
  description   = "Artifact Registry Repository for Container Images"
  format        = "DOCKER"
}




