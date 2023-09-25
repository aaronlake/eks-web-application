locals {
  env_map = {
    "Development" = "dev"
    "Production"  = "prod"
    "Demo"        = "demo"
  }

  env  = local.env_map[var.common_tags["Environment"]]
  name = lower(replace(var.common_tags["Application"], " ", ""))
}
