variable "aws_region" {
  type    = string
  default = ""
}

variable "local_kubeconfig_path" {
  type    = string
  default = ""
}

variable "image_repo_aws_load_balancer_controller" {
  type        = string
  description = "default value for region eu-west-2 for other region search through https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html"
  default     = "602401143452.dkr.ecr.eu-west-2.amazonaws.com/amazon/aws-load-balancer-controller"
}
#------------------Network setup-------------------

variable "vpc_id" {
  type        = string
  description = "VPC id where you desire to deploy"
  default     = ""
}

variable "internet_gateway_id" {
  type        = string
  description = "Internet gateway id of VPC"
  default     = ""
}

variable "public_subnet_cidrs" {
  type        = map(any)
  description = "Map - key = CIDR, value = availability zone"
  default = {
    "" = "eu-west-2a"
    "" = "eu-west-2b"
    "" = "eu-west-2c"
  }
}

variable "private_subnet_cidrs" {
  type        = map(any)
  description = "Map - key = CIDR, value = availability zone"
  default = {
    "" = "eu-west-2a"
    "" = "eu-west-2b"
    "" = "eu-west-2c"
  }
}

variable "public_subnets_ids_to_private" {
  type        = list(any)
  description = "List of public subnet IDs to attach each Nat gateway, match the values with the availability zones of the private subnet that the natgateway will be attached"
  default     = [""]
}

variable "shared_tags" {
  type        = map(any)
  description = "Common tags to all resources"
  default = {
    Owner   = "paulo.jesus"
    Team    = "sre"
    Project = "devops-challenge"
    Env     = "prod"
  }
}

variable "public_subnet_cluster_tag" {
  type        = map(any)
  description = "Tagging to allow cluster to deploy ELB using kubernetes annotations on service"
  default = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = 1
  }
}

variable "private_subnet_cluster_tag" {
  type        = map(any)
  description = "Tagging to allow cluster to deploy ELB using kubernetes annotations on service"
  default = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = 1
  }
}


#------------------Cluster variables----------------

variable "eks_cluster_name" {
  type    = string
  default = ""
}

variable "eks_cluster_version" {
  type    = string
  default = ""
}

variable "eks_managed_node_group_defaults" {
  type = map(any)
  default = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = [aws_security_group.allow-web-traffic.id]
  }
}

variable "eks_managed_node_groups" {
  type = map(any)
  default = {
    node_group_1 = {
      min_size     = 3
      max_size     = 3
      desired_size = 3

      instance_types = ["t3.medium"]
    }
  }
}


