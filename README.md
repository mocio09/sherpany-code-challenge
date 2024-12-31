# sherpany-code-challenge

## GitHub Actions Workflows for CI/CD

### Infrastructure Deployment (`deploy-infrastructure.yml`)
This workflow manages the infrastructure provisioning and configuration using Terraform (K8S deployment files for Database via Zalando Operator, VM for CloudScale, LBs) and Ansible (Grafana Agent configuration). It triggers on pull requests and pushes to the `main` branch that affect files in the `infrastructure/` or `playbooks/` directories. The workflow:
- Sets up Terraform and Ansible
- Initializes and plans infrastructure changes
- Applies infrastructure changes (only on main branch pushes)
- Configures the deployed infrastructure using Ansible playbooks


### Application Deployment (`deploy-app-to-registry.yml`)
This workflow handles the application's security scanning, building, and publishing process. It triggers on changes to the `api/` directory and can be manually triggered. The workflow:
- Performs security scans using Trivy on:
  - Python dependencies
  - Dockerfile
  - Built Docker image
- Builds the Docker image
- Publishes the image to DockerHub (using the tag 'latest')
- Fails the build if any high or critical security vulnerabilities are found

Note The workflows handle sensitive credentials and SSH keys securely through GitHub Secrets


## Infrastructure

The `infrastructure/` directory contains Terraform configurations that define and manage the complete infrastructure setup:

### Core Components
- `main.tf`: Configures the Terraform providers (Kubernetes, Helm, Cloudscale) and sets up the GCS backend for state management. Creates the main application namespace.
- `variables.tf`: Defines the required variables, including the Cloudscale API token.
- `outputs.tf`: Specifies output values for the Grafana agent's public IP and loadbalancer service IP.

### Application Infrastructure
- `api.tf`: Defines the Kubernetes deployment for the Flask application, including:
  - 3 replicas for high availability
  - Health check probes
  - Environment variables for database connection
  - LoadBalancer service configuration

### Database Setup
- `db.tf`: Configures the PostgreSQL database using Zalando's Postgres Operator:
  - Deploys a highly available PostgreSQL cluster (2 instances)
  - Sets up database users and permissions
  - Includes initialization job for database schema and sample data (The operator does not have default initialization out-of-the-box)

### Monitoring
- `cloudscale_server.tf`: Provisions a server on Cloudscale.ch for running the Grafana agent

### Security
- `firewall.tf`: Implements Kubernetes Network Policies to control pod-to-pod communication:
  - Restricts database access to only the Flask application pods
  - Secures the PostgreSQL port (5432)

## Playbooks

The `playbooks` directory contains the Ansible playbook and inventory for infrastructure configuration for the grafana agent on the VM
