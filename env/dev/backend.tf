terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = ">= 2.18"
    # }
  }
}

provider "aws" {
  version = "4.53.0"
  # profile = "haidt-profile-test"
  # access_key = ""
  # secret_key = ""
  region = var.region
}

# provider "kubernetes" {
#   host                   = module.main-eks.public_cluster_endpoint
#   cluster_ca_certificate = base64decode(module.main-eks.cluster_certificate_authority_data)

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", module.main-eks.cluster_name]
#   }
# }