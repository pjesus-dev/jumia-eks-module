data "aws_eks_cluster" "jumia-cluster" {
  name = module.my-cluster.cluster_id
}

data "aws_eks_cluster_auth" "jumia-cluster" {
  name = module.my-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.jumia-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.jumia-cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.jumia-cluster.token
}

module "my-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.2.3"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  subnet_ids      = [for s in aws_subnet.public_subnets : s.id]
  vpc_id          = var.vpc_id

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults
  eks_managed_node_groups         = var.eks_managed_node_groups
}





