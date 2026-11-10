module "apigee_npe" {
  source           = "../../modules/apigee_env_setup"
  project_id       = "prj-npe-apix-001"
  vpc_name         = "vpc-npe-apix-001"
  env_suffix       = "npe"
  primary_region   = "us-central1"
  enable_dr        = false
  environments     = ["dev", "qa", "uat"]
  hostnames        = ["dev-api.domain.com", "qa-api.domain.com", "uat-api.domain.com"]
}
