module "vpc" {
  source = "../../modules/network/vpc"

  project = var.project

  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  db_subnets      = var.db_subnets
}

module "security" {
  source  = "../../modules/security/security"
  project = var.project
  vpc_id  = module.vpc.vpc_id
  admin_cidr = "0.0.0.0/0"
}

module "eks" {
  source = "../../modules/compute/eks"

  project_name = var.project

  eks_cluster_version = var.eks_cluster_version 

  eks_subnet_ids     = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets

  cluster_security_group_id = module.security.eks_cluster_sg_id

  node_instance_type = "t3.micro"

  web_desired = 1
  web_min     = 1
  web_max     = 2

  was_desired = 1
  was_min     = 1
  was_max     = 2
}

module "rds" {
  source = "../../modules/database/rds"

  project    = var.project
  subnet_ids = module.vpc.db_subnets

  db_user = var.db_user
  db_pass = var.db_pass

  rds_sg_id = module.security.rds_sg_id
}

module "s3" {
  source = "../../modules/storage/s3"

  bucket_name = var.bucket_name
  project     = var.project
}