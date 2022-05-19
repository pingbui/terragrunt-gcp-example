locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl", "fallback.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl", "fallback.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl", "fallback.hcl"))
  project_id   = try(local.global_vars.locals.project_id, "example")
  region       = try(local.region_vars.locals.region, "us-east1")
  env          = try(local.env_vars.locals.env, "dev")
  env_desc     = try(local.env_vars.locals.env_desc, "example")
  project_name = try(local.global_vars.locals.project_name, "example")
}
