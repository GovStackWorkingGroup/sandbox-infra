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

resource "kubernetes_namespace" "govstack_backend_namespace" {
  metadata {
    annotations = {
      name = "govstack-backend"
    }

    labels = {
      mylabel = "govstack-backend"
    }

    name = "govstack-backend"
  }
}

resource "kubernetes_namespace" "govstack_namespace" {
  metadata {
    annotations = {
      name = "govstack"
    }

    labels = {
      mylabel = "govstack"
    }

    name = "govstack"


  }
}

resource "kubernetes_network_policy" "govstack_policy" {

  metadata {
    name      = "govstack-rules"
    namespace = "govstack"
  }

  spec {
    pod_selector {

    }

    ingress {
      ports {
        port     = "8443"
        protocol = "TCP"
      }
      from {
        namespace_selector {
          match_labels = {
            name = "govstack-backend"
          }
        }
      }
    }
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy" "govstack_backend_policy" {

  metadata {
    name      = "govstack-backend-rules"
    namespace = "govstack-backend"
  }

  spec {
    pod_selector {

    }

    ingress {
      ports {
        port     = "8081"
        protocol = "TCP"
      }
      from {
        namespace_selector {
          match_labels = {
            name = "govstack-ui"
          }
        }
      }
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
    }
    policy_types = ["Ingress", "Egress"]
  }
}
