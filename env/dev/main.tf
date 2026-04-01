module "vpc" {
  source  = "../../modules/network/vpc"
  project = "test2"
}

module "eks" {
  source     = "../../modules/compute/eks"
  subnet_ids = module.vpc.public_subnets

  cluster_role_arn = var.cluster_role_arn
  node_role_arn    = var.node_role_arn
}

module "rds" {
  source     = "../../modules/database/rds"
  subnet_ids = module.vpc.db_subnets
  vpc_id     = module.vpc.vpc_id

  eks_sg_id = module.eks.cluster_sg_id

  db_pass = var.db_pass
}

module "s3" {
  source = "../../modules/storage/s3"
  bucket_name = var.bucket_name
  project     = "test2"
}
