# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl", "global.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl", "./env/global/region.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl", "./env/env.hcl"))

  # Extract the variables we need for easy access
  project_name = try(local.global_vars.locals.project_name, "example")
  project_id   = try(local.global_vars.locals.project_id, "example")
  region       = try(local.region_vars.locals.region, "us-east1")
  env          = try(local.env_vars.locals.env, "dev")
  state_region = get_env("STATE_REGION", try(local.global_vars.locals.state_region, local.region))
}

terraform {
  extra_arguments "-var-file" {
    commands = get_terraform_commands_that_need_vars()
    optional_var_files = [
      find_in_parent_folders("group.tfvars", "ignore"),
    ]
  }
}

remote_state {
  backend = "gcs"

  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket   = get_env("STATE_BUCKET", format("${local.project_name}-tfstate-%s", local.state_region))
    prefix   = local.env != "common" ? "${path_relative_to_include()}/${local.env}" : "${path_relative_to_include()}" # "${replace(path_relative_to_include(), "env/", "${local.env}/")}/terraform.tfstate"
    project  = local.project_id
    location = local.state_region
  }
}

generate "providers" {
  path      = "_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  region  = "${local.region}"
  project = "${local.project_id}"
}
EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.global_vars.locals,
  local.region_vars.locals,
  local.env_vars.locals,
)
