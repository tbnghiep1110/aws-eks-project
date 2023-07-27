output "vpc_id" {
  value = module.main-vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.main-vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.main-vpc.public_subnet_ids
}