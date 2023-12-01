variable "sandbox_alb_listener_arn" {
  type = string
}

variable "sandbox_alb_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_domain" {
  description = "Sandbox ALB domain"
  type        = string
  nullable    = true
}

variable "user_pool_arn" {
  type        = string
  nullable    = true
}

variable "user_pool_domain" {
  type        = string
  nullable    = true
}

variable "user_pool_client_id" {
  type        = string
  nullable    = true
}