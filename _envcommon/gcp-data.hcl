terraform {
  source = "github.com/pingbui/terraform-modules.git//gcp-data?ref=0.3.1"
}

## Dependencies:
dependencies {
  paths = [
    "${dirname(find_in_parent_folders())}/common/global/project-services",
  ]
}

## Variables:
inputs = {
}
