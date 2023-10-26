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
    {
      rolearn  = module.eks_blueprints_kubernetes_addons.karpenter.node_iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
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
  version = "~> 19.0"

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
    ami_type = "AL2_x86_64"
    instance_types = [var.instance_type]
    attach_cluster_primary_security_group = true
    use_custom_launch_template = false
    disk_size = var.disk_size
    disk_type = "gp3"
    asg_max_size = 16
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"
      subnet_ids     = [module.vpc.private_subnets[0]]
    }

    two = {
      name = "node-group-2"
      subnet_ids     = [module.vpc.private_subnets[1]]
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

# Required for public ECR where Karpenter artifacts are hosted
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

module "eks_blueprints_kubernetes_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  enable_aws_load_balancer_controller = true
  enable_metrics_server               = true
  enable_karpenter                    = true

  aws_load_balancer_controller = { 
    wait = true
  }
  
  karpenter = {
    depends_on = [module.eks_blueprints_kubernetes_addons.aws_load_balancer_controller]
    repository = "oci://public.ecr.aws/karpenter"
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
  }

  tags = {
    "karpenter.sh/discovery" = module.eks.cluster_name
  }
}

#https://karpenter.sh/preview/concepts/provisioners/
resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: default
    spec:
      consolidation: 
        enabled: true
      requirements:
        - key: "karpenter.k8s.aws/instance-family"
          operator: In
          values: ["t3", "t3a"]
        - key: "karpenter.k8s.aws/instance-size"
          operator: In
          values: ["medium", "large", "xlarge", "2xlarge"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
      limits:
        resources:
          cpu: 1000
      requests:
        resources:
          ephemeral-storage: "100Gi"
      providerRef:
        name: default
      ttlSecondsUntilExpired: 2592000 # 30 Days = 60 * 60 * 24 * 30 Seconds;
  YAML

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
}

resource "kubectl_manifest" "karpenter_node_template" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: default
    spec:
      blockDeviceMappings:
        - deviceName: /dev/xvda
          ebs:
            volumeType: gp3
            volumeSize: 100Gi
            deleteOnTermination: true
      subnetSelector:
        kubernetes.io/cluster/${var.cluster_name}: shared
      securityGroupSelector:
        kubernetes.io/cluster/${var.cluster_name}: '*'
      instanceProfile: ${module.eks_blueprints_kubernetes_addons.karpenter.node_instance_profile_name}
      tags:
        karpenter.sh/discovery: ${var.cluster_name}
  YAML

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
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
