variable "project_id" { type = string }
variable "vpc_name" { type = string }
variable "env_suffix" { type = string }
variable "primary_region" { type = string }
variable "dr_region" { default = "us-east4", type = string }
variable "enable_dr" { default = false, type = bool }
variable "analytics_region" { default = "us-central1", type = string }
variable "billing_type" { default = "PAYG", type = string }
variable "environments" { type = list(string) }
variable "hostnames" { type = list(string) }
