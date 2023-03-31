module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.11.0"

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version
  cluster_enabled_log_types = ["api", "audit"]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn = "arn:aws:iam::${var.account_id}:role/SandboxAdmin",
      username = "SandboxAdmin"
      groups   = ["system:masters"]
    },
    {
      rolearn = "arn:aws:iam::${var.account_id}:role/SandboxDeveloper",
      username = "SandboxDeveloper"
      groups   = ["system:masters"]
    },
    {
      rolearn = "arn:aws:iam::${var.account_id}:role/CircleCIRole",
      username = "system:node:EKSGetTokenAuth",
      groups   = ["system:masters"]
    }
  ]

  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    attach_cluster_primary_security_group = true

    # Disabling and using externally provided security groups
    create_security_group = false
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["m5.large"]

      min_size     = 1
      desired_size = 2
      max_size     = 4
      

      vpc_security_group_ids = [
        aws_security_group.node_group_one.id
      ]
    }

    two = {
      name = "node-group-2"

      instance_types = ["m5.large"]

      min_size     = 1
      desired_size = 2
      max_size     = 4
      

      vpc_security_group_ids = [
        aws_security_group.node_group_two.id
      ]
    }
  } 

}

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints/modules/kubernetes-addons"

  eks_cluster_id       = module.eks.cluster_name
  enable_amazon_eks_aws_ebs_csi_driver = true
}
