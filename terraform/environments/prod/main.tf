module "apigee_prod" {
  source           = "../../modules/apigee_env_setup"
  project_id       = "prj-prod-apix-001"
  vpc_name         = "vpc-prod-apix-001"
  env_suffix       = "prod"
  primary_region   = "us-central1"
  dr_region        = "us-east4"
  enable_dr        = true
  environments     = ["prod"]
  hostnames        = ["api.domain.com"]
}
