output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "The name of the GKE cluster."
}
output "gsa_email" {
  value       = google_service_account.gke_sa.email
  description = "The email of the GCP service account used for Workload Identity."
}
output "artifact_registry_url" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
  description = "The URL of the Artifact Registry repository."
}
