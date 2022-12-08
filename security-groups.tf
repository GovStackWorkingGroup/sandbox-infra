resource "aws_security_group" "node_group_one" {
  name_prefix = "node_group_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "node_group_two" {
  name_prefix = "node_group_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "kubernetes_network_policy" "default_policy" {

  metadata {
    name      = "default-rules"
    namespace = "default"
  }

  spec {
    pod_selector {

    }

    ingress {

    }

    egress {
      ports {
        port     = "53"
        protocol = "UDP"
      }
      to {
        namespace_selector {
          match_labels = {
            name = "kube-system"
          }
        }
      }

    } # single empty rule to allow all egress traffic

    policy_types = ["Ingress", "Egress"]
  }
}