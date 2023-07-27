module "main-eks" {
  source             = "../../modules/eks"
  depends_on         = [module.main-vpc, module.main-ec2]
  public_subnet_ids  = module.main-vpc.public_subnet_ids
  private_subnet_ids = module.main-vpc.private_subnet_ids
  vpc_id             = module.main-vpc.vpc_id
}


