output "org_id" {
  value = google_apigee_organization.apigee_org.id
}
output "vpc_id" {
  value = google_compute_network.apigee_vpc.id
}
