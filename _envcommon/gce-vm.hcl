terraform {
  source = "github.com/terraform-google-modules/terraform-google-vm.git//modules/compute_instance?ref=v7.7.0"
}

## Dependencies:
dependencies {
  paths = [
    "${dirname(find_in_parent_folders())}/env/${local.region}/gce/templates/${local.name}",
    "${dirname(find_in_parent_folders())}/env/${local.region}/ips",
    "${dirname(find_in_parent_folders())}/env/${local.region}/vpc"
  ]
}

dependency "template" {
  config_path = "${dirname(find_in_parent_folders())}/env/${local.region}/gce/templates/${local.name}"
}

dependency "ip" {
  config_path = "${dirname(find_in_parent_folders())}/env/${local.region}/ips"
}

dependency "vpc" {
  config_path = "${dirname(find_in_parent_folders())}/env/${local.region}/vpc"
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

  labels = merge(
    try(local.global_vars.locals.labels, {}),
    {
      name = lower("${local.name_prefix}-${local.name}")
      env  = lower(local.env_desc)
    }
  )
}

inputs = {
  hostname            = lower("${local.name_prefix}-${local.name}")
  add_hostname_suffix = false
  project_id          = local.project_id
  region              = local.region
  num_instances       = 1
  subnetwork          = dependency.vpc.outputs.subnets_names[1]
  subnetwork_project  = local.project_id
  instance_template   = dependency.template.outputs.self_link
  deletion_protection = try(local.global_vars.locals.gce_settings["deletion_protection"], false)

  access_config = [{
    nat_ip       = dependency.ip.outputs.addresses[index(dependency.ip.outputs.names, lower("${local.name_prefix}-${local.name}"))]
    network_tier = "PREMIUM"
    },
  ]
}
