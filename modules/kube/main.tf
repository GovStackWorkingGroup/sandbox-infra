data "aws_eks_cluster" "sandbox" {
  name = "${var.cluster_name}"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.sandbox.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.sandbox.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.sandbox.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.sandbox.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}