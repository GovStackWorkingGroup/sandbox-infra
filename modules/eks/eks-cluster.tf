locals {
  user_role_map = tolist([
    {
      rolearn  = "arn:aws:iam::${var.account_id}:role/SandboxAdmin",
      username = "SandboxAdmin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${var.account_id}:role/SandboxDeveloper",
      username = "SandboxDeveloper"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${var.account_id}:role/CircleCIRole",
      username = "system:node:EKSGetTokenAuth",
      groups   = ["system:masters"]
    },
  ])
  cicd_role_map = tolist([
    for role_arn in var.cicd_rolearns : {
      rolearn  = role_arn
      username = "system:node:EKSGetTokenAuth",
      groups   = ["system:masters"]
    }
  ])

  aws_auth_map = concat(local.user_role_map, local.cicd_role_map)
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.11.0"

  cluster_name              = var.cluster_name
  cluster_version           = var.eks_version
  cluster_enabled_log_types = ["api", "audit"]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  #create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  aws_auth_roles            = local.aws_auth_map

  cluster_endpoint_public_access = true
  create_cluster_security_group  = false
  create_node_security_group     = false

  eks_managed_node_group_defaults = {
    ami_type                              = "AL2_x86_64"
    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      #instance_types = ["m5.large"]
      instance_types = [var.instance_type]
      subnet_ids     = [module.vpc.private_subnets[0]]

      use_custom_launch_template = false
      disk_size                  = var.disk_size

      min_size     = 1
      desired_size = 2
      max_size     = 4

    }

    two = {
      name = "node-group-2"

      #instance_types = ["m5.large"]
      instance_types = [var.instance_type]
      subnet_ids     = [module.vpc.private_subnets[1]]

      use_custom_launch_template = false
      disk_size                  = var.disk_size

      min_size     = 1
      desired_size = 2
      max_size     = 4

    }
  }

}

module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${var.cluster_name}-ebs-csi-controller-sa-irsa"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "eks_blueprints_kubernetes_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_load_balancer_controller = true
  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "auth_map" {
  value = local.aws_auth_map
}

output "region" {
  value = var.region
}
