# Default locals
locals {
  # tags
  default_tags = {
    env       = var.env
    terraform = "true"
    platform  = var.platform
  }
}