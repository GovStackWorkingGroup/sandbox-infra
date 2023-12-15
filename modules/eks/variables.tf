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

variable "account_id" {
  type = string
#  default = data.aws_caller_identity.current.account_id
}

variable "cicd_rolearns" {
  type = list(string)
  default = []
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
}

variable "disk_size" {
  description = "Disk Size"
  type        = number
}

variable "alb_certificate_arn" {
  description = "Sandbox ALB TLS certificate"
  type        = string
  nullable    = true
}

variable "ext_roles" {
  type = list(string)
  default = []
}