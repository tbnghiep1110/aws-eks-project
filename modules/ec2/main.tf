resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  count         = var.number_of_instances
  subnet_id     = flatten([module.main-vpc.public_subnet_ids, module.main-vpc.private_subnet_ids])[0]
  instance_type = var.instance_type
  key_name      = var.ami_key_pair_name
}

module "main-vpc" {
  source = "../../modules/vpc"
  #   cidr_block = var.vpc_cidr
}