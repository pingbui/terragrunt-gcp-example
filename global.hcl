locals {
  project_name   = get_env("PROJECT_NAME", "example")
  project_id     = get_env("PROJECT_ID", "example")
  operation_team = get_env("OPERATION_TEAM", "admin")
  noti_user      = get_env("NOTI_USER", "admin")
  noti_domain    = get_env("NOTI_DOMAIN", "example.com")
  time_zone      = get_env("TIME_ZONE", "Asia/Tokyo")
  ssh_user       = get_env("SSH_USER", local.project_name)

  mnt_ips = {
    "${local.operation_team}_ip1" = "1.2.3.4/32",
    "${local.operation_team}_ip2" = "5.6.7.8/32",
  }

  ## Project services:
  activate_apis = [
    "compute.googleapis.com",
    "servicenetworking.googleapis.com"
  ]

  ## For VPCs:
  vpc_settings = {
    routing_mode = "REGIONAL"
    cidr_newbits = 4
    cidrs = {
      dev   = { "us-east1" = "10.1.0.0/16" }
      test  = { "us-east1" = "10.2.0.0/16" }
      stage = { "us-east1" = "10.3.0.0/16" }
      prod  = { "us-east1" = "10.8.0.0/16" }
    }
  }

  ## GCE:
  gce_settings = {
    dev = {
      bastion = {
        machine_type = "e2-micro"
        tagname      = "bastion"
        disk_size    = 20
        disk_type    = "pd-ssd"
      }
    }

    prod = {
      prompt_color = "31m"

      bastion = {
        machine_type = "e2-micro"
        tagname      = "bastion"
        disk_size    = 20
        disk_type    = "pd-ssd"
      }
    }
  }

  ## SSH User:
  ssh_users = {
    dev   = lower(local.operation_team)
    stage = lower(local.operation_team)
    test  = lower(local.operation_team)
    prod  = lower(local.operation_team)
  }

  ## Bucket locations:
  #  https://cloud.google.com/storage/docs/locations
  state_region = get_env("STATE_REGION", "us-east1")
  storage_settings = {
    force_destroy = false
    versioning    = false
    class         = "STANDARD"
    locations = {
      prod = "us"
    }
  }

  ## GLOBAL labels:
  labels = {
    namespace = lower(local.project_name)
    managedby = lower(local.operation_team)
  }
}
