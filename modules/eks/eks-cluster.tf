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
    {
      rolearn = "arn:aws:iam::${var.account_id}:role/EXT-mifosGroupIAMRole"
      username = "EXT-mifosGroup"
      groups = ["system:masters"]
    }
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
    min_size     = 1
    max_size     = 4
    desired_size = 2
  }

  eks_managed_node_groups = {
    default = {
      subnet_ids    = module.vpc.private_subnets
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

module "vpc_cni_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${var.cluster_name}-vpc-cni-irsa"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
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
  version = "1.12.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
    vpc-cni = {
      most_recent = true
      service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn
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
    chart_version = "v0.32.1"
  }

  tags = {
    "karpenter.sh/discovery" = module.eks.cluster_name
  }
}

#https://karpenter.sh/preview/concepts/nodepools/
resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          nodeClassRef:
            name: default
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
      disruption:
          consolidationPolicy: WhenUnderutilized
          expireAfter: 2592000s # 30 Days = 60 * 60 * 24 * 30 Seconds;
      limits:
        cpu: "1000"
  YAML

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
}

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2
      role: "${module.eks_blueprints_kubernetes_addons.karpenter.node_iam_role_name}"
      blockDeviceMappings:
        - deviceName: /dev/xvda
          ebs:
            volumeType: gp3
            volumeSize: 100Gi
            deleteOnTermination: true
      subnetSelectorTerms:
        - tags:
            kubernetes.io/cluster/${var.cluster_name}: shared
            Name: "${var.cluster_name}_private"
      securityGroupSelectorTerms:
        - tags:
            kubernetes.io/cluster/${var.cluster_name}: '*'
      tags:
        karpenter.sh/discovery: ${var.cluster_name}
  YAML

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
}

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" : "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    fsType    = "ext4"
    encrypted = true
    type      = "gp3"
  }
}

resource "null_resource" "kubectl" {
  provisioner "local-exec" {
      command = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
  }
  depends_on = [module.eks]
}

resource "null_resource" "remove_gp2_aws_ebs_storage_class" {
  provisioner "local-exec" {
    command = "kubectl delete storageclass gp2"
    on_failure = continue
  }
  depends_on = [null_resource.kubectl]
}

resource "null_resource" "add_service_monitoring_crd" {
   provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml"
    on_failure = continue
  }
  depends_on = [null_resource.kubectl]
}

resource "null_resource" "add_service_monitoring_crd" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml"
    on_failure = continue
  }

  depends_on = [module.eks]
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
