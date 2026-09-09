variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "region" {
  description = "The region in which to provision resources."
  type        = string
}
variable "gke_cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC network."
  type        = string
}
variable "subnet_name" {
  description = "The name of the subnet."
  type        = string
}
variable "subnet_ip_range" {
  description = "The IP range for the subnet."
  type        = string
}
variable "pods_ip_range" {
  description = "The IP range for GKE pods."
  type        = string
}
variable "services_ip_range" {
  description = "The IP range for GKE services."
  type        = string
}
variable "master_ipv4_cidr_block" {
  description = "The CIDR block for the GKE master."
  type        = string
}
variable "primary_node_pool_name" {
  description = "The name of the primary node pool."
  type        = string
}
variable "repo_id" {
  description = "The ID of the repository."
  type        = string
}