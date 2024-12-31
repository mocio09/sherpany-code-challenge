# Install the PostgreSQL Operator
resource "helm_release" "postgres_operator" {
  name       = "postgres-operator"
  namespace  = "application"
  repository = "https://opensource.zalando.com/postgres-operator/charts/postgres-operator"
  chart      = "postgres-operator"

  # Set values for the chart if needed
  values = [
    <<EOF
# Example of overriding default values
configGeneral:
  enable_crd_validation: true
EOF
  ]
}

resource "kubernetes_config_map" "db_init_script" {
  metadata {
    name = "db-init-script"
    namespace = "application"
  }
  data = {
    "init.sql" = file("${path.module}/init.sql")
  }
}

# Create the PostgreSQL database instance - does not support init script , see : https://github.com/zalando/postgres-operator/issues/775
resource "kubernetes_manifest" "acid_minimal_cluster" {
  manifest = {
    apiVersion = "acid.zalan.do/v1"
    kind       = "postgresql"
    metadata = {
      name      = "pg-cluster"
      namespace = kubernetes_namespace.application_namespace.metadata[0].name
    }
    spec = {
      teamId            = "acid"
      volume            = { size = "1Gi" }
      numberOfInstances = 2
      
      users = {
        zalando  = ["superuser", "createdb"]
        foo_user = []
      }
      databases = {
        production = "zalando"
      }
      postgresql = {
        version = "17"
      }
    }
  }
}

## Workaround for the init script not being executed, use a job to execute the init script
resource "kubernetes_job_v1" "db_init_job" {
  metadata {
    name      = "db-init-job"
    namespace = "application"
  }

  spec {
    template {
      metadata {
        labels = {
          "app" = "db-init-job"
        }
      }

      spec {
        container {
          name  = "db-init"
          image = "postgres:17"

          env {
            name = "PGPASSWORD"
            value_from {
              secret_key_ref {
                name = "zalando.pg-cluster.credentials.postgresql.acid.zalan.do"
                key  = "password"
              }
            }
          }

          # Equivalent to command: ["/bin/bash"]
          # and args: ["-c", "psql ... /scripts/init.sql"]
          command = [ "/bin/bash" ]
          args    = [
            "-c",
            "psql -h pg-cluster -U zalando -d production -f /scripts/init.sql"
          ]

          volume_mount {
            name       = "init-scripts"
            mount_path = "/scripts"
            read_only  = true
          }
        }

        volume {
          name = "init-scripts"

          config_map {
            # Reference the ConfigMap we created above
            name = kubernetes_config_map.db_init_script.metadata[0].name
          }
        }

        # Prevent the Job pods from restarting indefinitely
        restart_policy = "Never"
      }
    }
  }
  depends_on = [ kubernetes_manifest.acid_minimal_cluster  ]
}

