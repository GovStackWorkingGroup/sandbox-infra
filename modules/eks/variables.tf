# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
}

variable "region" {
  description = "AWS region"
  type = string
  default = "eu-central-1"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "eks_version" {
  type = string
}

variable "environment" {
  type = string
}