resource "kubernetes_deployment" "flask_app" {
  metadata {
    name = "flask-app"
    labels = {
      app = "flask-app"
    }
    namespace = kubernetes_namespace.application_namespace.metadata[0].name
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "flask-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "flask-app"
        }
      }

      spec {
        container {
          name  = "flask-app"
          image = "mocio/flask-app:latest"

          port {
            container_port = 8080
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 15
          }

          # Adding environment variables
          env {
            name  = "DB_HOST"
            value = "pg-cluster"
          }

          env {
            name  = "DB_PORT"
            value = "5432"
          }

          env {
            name  = "DB_NAME"
            value = "production"
          }

          env {
            name  = "DB_USER"
            value = "zalando"
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "zalando.pg-cluster.credentials.postgresql.acid.zalan.do"
                key  = "password"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "loadbalancer_service" {
  metadata {
    name = "flask-app-lb"
    annotations = {
      "load-balancer.hetzner.cloud/type" = "external" # Adjust for Cloudscale.ch-specific annotations
    }
    namespace = kubernetes_namespace.application_namespace.metadata[0].name
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = "flask-app" # Matches the label of your Pods/Deployment
    }

    port {
      protocol    = "TCP"
      port        = 80        # Port exposed by the load balancer
      target_port = 8080      # Port your app listens on in the Pod
    }
  }
}

