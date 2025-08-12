variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Used region for regional resources"
}

variable "service_attachment_id" {
  type        = string
  description = "Service Attachment ID of the published service."
}

# IP Address
resource "google_compute_address" "consumer_apache_web_server_endpoint" {
  name         = "consumer-apache-web-server-endpoint"
  region       = var.region
  subnetwork   = google_compute_subnetwork.consumer_endpoint.id
  address_type = "INTERNAL"
}

# PSC endpoint
resource "google_compute_forwarding_rule" "consumer_endpoint" {
  name                    = "consumer-endpoint"
  region                  = var.region
  network                 = google_compute_network.consumer_endpoint.id
  ip_address              = google_compute_address.consumer_apache_web_server_endpoint.id
  target                  = var.service_attachment_id
  load_balancing_scheme   = "" # Explicit empty string required for PSC
}

resource "google_compute_network" "consumer_endpoint" {
  name                    = "consumer-endpoint"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "consumer_endpoint" {
  name                     = "consumer-endpoint-${var.region}"
  ip_cidr_range            = "172.16.0.0/29"
  region                   = var.region
  network                  = google_compute_network.consumer_endpoint.name
  private_ip_google_access = true
}