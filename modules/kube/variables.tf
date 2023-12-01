# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  type        = string
}

variable "environment" {
  type = string
}

variable "account_id" {
  type = string
#  default = data.aws_caller_identity.current.account_id
}
