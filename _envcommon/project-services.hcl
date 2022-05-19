terraform {
  source = "github.com/terraform-google-modules/terraform-google-project-factory.git//modules/project_services?ref=v13.0.0"
}

## Variables:
locals {
  global_vars   = read_terragrunt_config(find_in_parent_folders("global.hcl", "fallback.hcl"))
  project_id    = try(local.global_vars.locals.project_id, "example")
  activate_apis = try(local.global_vars.locals.activate_apis, ["compute.googleapis.com"])
}

inputs = {
  project_id    = local.project_id
  activate_apis = local.activate_apis
}
