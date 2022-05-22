# Terragrunt/Terraform
Terragrunt and terraform template for GCP

## Requirements:
1. [Terraform](https://www.terraform.io/): version ~> v1.2.0
2. [Terragrunt](https://terragrunt.gruntwork.io/): version ~> v0.37.1
3. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install): version ~> 384.0.1
4. Edit $HOME/[.terraformrc](https://www.terraform.io/docs/commands/cli-config.html):
```bash
mkdir -p $HOME/.terraform.d/plugins
tee $HOME/.terraformrc <<-EOF
plugin_cache_dir = "\$HOME/.terraform.d/plugins"
disable_checkpoint = true
EOF
```

## Alias:
```bash
alias tg='terragrunt'
alias tgh='tg hclfmt'
alias tga='tgh && tg apply'
alias tgp='tgh && tg plan'
```

## Steps to provision:

### Set default login:
```bash
gcloud auth application-default login
```

### Active services' API:
```bash
(cd common/global/project-services && tg apply)
```

### Set environment from ENV before provisoning env's resources (Default is 'dev'):
```
## Test env:
export ENV=test

## Staging env:
export ENV=stage

## Production env:
export ENV=prod
```

### Env's resources:
```bash
(cd env/us-east1/<resource-dir> && tg apply)
```
