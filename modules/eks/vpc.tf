

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.cluster_name
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = cidrsubnets(cidrsubnet(var.vpc_cidr, 1, 0), 5, 5, 5)
  public_subnets  = cidrsubnets(cidrsubnet(var.vpc_cidr, 1, 1), 7, 7, 7)

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    Name                                        = "${var.cluster_name}_public"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
    Name                                        = "${var.cluster_name}_private"
  }

  #tags = local.tags
}
