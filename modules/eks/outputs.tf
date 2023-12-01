output "vpc_id" {
    value = module.vpc.vpc_id
}

output "sandbox_alb_arn" {
    value = aws_lb.sandbox_alb.arn
}

output "sandbox_alb_listener_arn" {
    value = aws_lb_listener.sandbox_alb.arn
}

output "sandbox_cluster_name" {
    value = module.eks.cluster_name
}