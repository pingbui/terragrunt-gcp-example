terraform {
  source = "github.com/terraform-google-modules/terraform-google-service-accounts.git?ref=v4.1.1"
}

## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl", "fallback.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl", "fallback.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl", "fallback.hcl"))
  project_id   = try(local.global_vars.locals.project_id, "example")
  region       = try(local.region_vars.locals.region, "us-east1")
  env          = try(local.env_vars.locals.env, "dev")
  env_desc     = try(local.env_vars.locals.env_desc, "example")
  project_name = try(local.global_vars.locals.project_name, "example")
  name         = basename(get_terragrunt_dir())
  name_prefix  = lower("${local.project_name}-${local.env}")

}

inputs = {
  names         = [lower("${local.name_prefix}-${local.name}")]
  description   = "Service accounts for ${local.name_prefix}-${local.name}"
  display_name  = "Service accounts for ${local.name_prefix}-${local.name}"
  project_id    = local.project_id
  project_roles = try(local.global_vars.locals.iam_settings[local.name], ["${local.project_id}=>roles/viewer"])
}
