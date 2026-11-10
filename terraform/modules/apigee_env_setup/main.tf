terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_project_service" "apigee_services" {
  for_each = toset([
    "apigee.googleapis.com",
    "apigeeconnect.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com"
  ])
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_compute_network" "apigee_vpc" {
  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
  depends_on              = [google_project_service.apigee_services]
}

resource "google_compute_global_address" "apigee_range" {
  name          = "apigee-peering-range-${var.env_suffix}"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 22
  network       = google_compute_network.apigee_vpc.id
}

resource "google_service_networking_connection" "apigee_peering" {
  network                 = google_compute_network.apigee_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.apigee_range.name]
}

resource "google_apigee_organization" "apigee_org" {
  analytics_region   = var.analytics_region
  project_id         = var.project_id
  authorized_network = google_compute_network.apigee_vpc.id
  billing_type       = var.billing_type
  depends_on         = [google_service_networking_connection.apigee_peering]
}

resource "google_apigee_instance" "apigee_instance_primary" {
  name               = "apigee-instance-${var.primary_region}"
  location           = var.primary_region
  org_id             = google_apigee_organization.apigee_org.id
  peering_cidr_range = "SLASH_22"
}

resource "google_apigee_instance" "apigee_instance_dr" {
  count              = var.enable_dr ? 1 : 0
  name               = "apigee-instance-${var.dr_region}"
  location           = var.dr_region
  org_id             = google_apigee_organization.apigee_org.id
  peering_cidr_range = "SLASH_22"
}

resource "google_apigee_environment" "apigee_envs" {
  for_each     = toset(var.environments)
  name         = each.value
  org_id       = google_apigee_organization.apigee_org.id
  display_name = upper(each.value)
}

resource "google_apigee_envgroup" "env_group" {
  name      = "${var.env_suffix}-group"
  org_id    = google_apigee_organization.apigee_org.id
  hostnames = var.hostnames
}

resource "google_apigee_envgroup_attachment" "env_attachments" {
  for_each    = toset(var.environments)
  envgroup_id = google_apigee_envgroup.env_group.id
  environment = google_apigee_environment.apigee_envs[each.value].name
}

resource "google_apigee_instance_attachment" "instance_attachments" {
  for_each    = toset(var.environments)
  instance_id = google_apigee_instance.apigee_instance_primary.id
  environment = google_apigee_environment.apigee_envs[each.value].name
}
