terraform {
  source = "github.com/terraform-google-modules/terraform-google-network.git?ref=v5.0.0"
}

## Dependencies:
dependencies {
  paths = []
}

## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  project_id   = try(local.global_vars.locals.project_id, "example")
  region       = try(local.region_vars.locals.region, "us-east1")
  env          = try(local.env_vars.locals.env, "dev")
  name         = lower("${local.global_vars.locals.project_name}-${local.env}")
  cidr         = try(local.global_vars.locals.vpc_settings["cidrs"][local.env][local.region], "10.200.0.0/20")
  cidr_newbits = try(local.global_vars.locals.vpc_settings["cidr_newbits"], "4")
}

inputs = {
  network_name = local.name
  project_id   = local.project_id
  routing_mode = try(local.global_vars.locals.vpc_settings["routing_mode"], "REGIONAL")

  subnets = [
    {
      subnet_name   = "${local.name}-public"
      subnet_ip     = "${cidrsubnet(local.cidr, local.cidr_newbits, 0)}"
      subnet_region = local.region
    },
    {
      subnet_name           = "${local.name}-private"
      subnet_ip             = "${cidrsubnet(local.cidr, local.cidr_newbits, 1)}"
      subnet_region         = local.region
      subnet_private_access = "true"
    }
  ]
}
