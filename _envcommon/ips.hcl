terraform {
  source = "github.com/terraform-google-modules/terraform-google-address.git?ref=v3.1.1"
}

## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  project_id   = try(local.global_vars.locals.project_id, "example")
  region       = try(local.region_vars.locals.region, "us-east1")
  env          = try(local.env_vars.locals.env, "dev")
  project_name = local.global_vars.locals.project_name
  names        = ["bastion"]
}

inputs = {
  names        = formatlist("${local.project_name}-${local.env}-%s", local.names)
  project_id   = local.project_id
  region       = local.region
  global       = false
  subnetwork   = ""
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}
