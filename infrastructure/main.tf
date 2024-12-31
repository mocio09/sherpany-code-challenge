terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    cloudscale = {
      source  = "cloudscale-ch/cloudscale"
    }
  }
}

terraform {
  backend "gcs" {
    bucket  = "code-challenge-temporary-k8s"
    prefix  = "terraform"
    credentials = "service-account.json"
  }
}

provider "kubernetes" {
  config_path = "./kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "./kubeconfig"
  }
}

# Create a namespace
resource "kubernetes_namespace" "application_namespace" {
  metadata {
    name = "application"
  }
}