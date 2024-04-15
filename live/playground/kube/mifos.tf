#
# Target groups
# TargetGroupBinding resource binds actual endpoints to the tg
#
resource "aws_lb_target_group" "mifos-ui" {
    name = "mifos-ui-tg"
    port = 80
    vpc_id = var.vpc_id
    protocol = "HTTP"
    target_type = "ip"
}

locals {
  backends = {
    mifos-ui = {
      namespace = "paymenthub"
      service = "ph-ee-operations-web"
      tg = aws_lb_target_group.mifos-ui
    }
  }
}
