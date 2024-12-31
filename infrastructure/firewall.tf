resource "kubernetes_network_policy" "allow_flask_to_postgres" {
  metadata {
    name      = "allow-flask-to-postgres"
    namespace = kubernetes_namespace.application_namespace.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        cluster-name = "pg-cluster" # Target PostgreSQL Pods
      }
    }

    policy_types = ["Ingress"]

    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "flask-app" # Allow traffic from Flask Pods
          }
        }
      }

      

      ports {
        protocol = "TCP"
        port     = 5432 # PostgreSQL port
      }
    }
  }
}
