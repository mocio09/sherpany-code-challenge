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

provider "kubernetes" {
  config_path = "~/Downloads/kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "~/Downloads/kubeconfig"
  }
}

# Create a namespace
resource "kubernetes_namespace" "application_namespace" {
  metadata {
    name = "application"
  }
}