output "grafana_agent_public_ip" {
  value = cloudscale_server.grafana_agent.public_ipv4_address
}

output "loadbalancer_service_public_ip" {
  value = kubernetes_service.loadbalancer_service.status[0].load_balancer[0].ingress[0].ip
}