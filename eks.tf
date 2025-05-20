module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"

  cluster_name    = "hackathon-eks-cluster"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    dev_nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  enable_irsa = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
