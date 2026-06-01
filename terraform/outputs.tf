output "cluster_name" {
  value = google_container_cluster.main.name
}

output "cluster_location" {
  value = google_container_cluster.main.location
}

output "registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/k8s-gcp-registry"
}

output "gke_nodes_service_account" {
  value = google_service_account.gke_nodes.email
}
