module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = "${var.cluster_name}"
  cluster_version = "${var.eks_version}"
  cluster_enabled_log_types = ["api", "audit"]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  fargate_profiles = {
    fargate = {
      name      = "${var.cluster_name}"
      selectors = [
        {
          namespace = "backend"
          labels    = {
            Application = "backend"
          }
          subnet_ids = module.vpc.private_subnets
        },
        {
          namespace = "default"
          labels    = {
            Application = "default"
          }
          subnet_ids = module.vpc.private_subnets
        }
      ]

      # Using specific subnets instead of the subnets supplied for the cluster itself
      #subnet_ids = [module.vpc.private_subnets[1]]
      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    attach_cluster_primary_security_group = true

    # Disabling and using externally provided security groups
    create_security_group = false
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 1
      desired_size = 1


      vpc_security_group_ids = [
        aws_security_group.node_group_one.id
      ]
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      vpc_security_group_ids = [
        aws_security_group.node_group_two.id
      ]
    }
  }
}

resource "aws_ecs_cluster" "govstack_cluster" {
  name = "${var.cluster_name}"
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.govstack_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 50
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_cluster_capacity_providers" "fargate_spot" {
  cluster_name = aws_ecs_cluster.govstack_cluster.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 50
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_ecr_repository" "GovStack_ECR" {
  name                 = "govstackecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
