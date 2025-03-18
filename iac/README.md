# Infrastructure as Code (IaC)

This directory contains all infrastructure-related code for our project using Terraform to manage AWS cloud resources. The infrastructure includes a complete EKS cluster with comprehensive observability and service mesh capabilities.

## Overview

This infrastructure code follows Infrastructure as Code (IaC) principles, using Terraform to provision and manage AWS cloud resources in a reliable, repeatable, and version-controlled manner. It sets up a production-grade Kubernetes cluster with integrated monitoring, logging, tracing, and service mesh capabilities.

## Directory Structure

```
iac/
├── modules/                    # Reusable Terraform modules
│   ├── vpc/                   # VPC and networking configuration
│   │   ├── main.tf           # VPC resources
│   │   ├── variables.tf      # Input variables
│   │   └── outputs.tf        # Output values
│   │
│   └── eks/                   # EKS cluster configuration
│       ├── main.tf           # EKS cluster resources
│       ├── variables.tf      # Input variables
│       ├── outputs.tf        # Output values
│       └── controllers/      # Kubernetes controllers and add-ons
│           ├── main.tf      # Common resources
│           ├── grafana.tf   # Grafana deployment
│           ├── prometheus.tf # Prometheus stack
│           ├── loki.tf      # Logging stack
│           ├── tempo.tf     # Distributed tracing
│           ├── istio.tf     # Service mesh
│           └── templates/   # Helm values and configuration templates
│               ├── grafana-values.yaml     # Grafana configuration
│               ├── prometheus-values.yaml  # Prometheus configuration
│               ├── loki-values.yaml       # Loki configuration
│               ├── tempo-values.yaml      # Tempo configuration
│               ├── istiod-values.yaml     # Istio control plane configuration
│               ├── istio-ingress-values.yaml # Istio gateway configuration
│               └── kiali-values.yaml      # Kiali dashboard configuration
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
└── README.md                  # This file
```

## Modules Description

### VPC Module
Located in `modules/vpc/`, this module manages the Virtual Private Cloud configuration including:
- VPC with customizable CIDR block
- 3 public and 3 private subnets across different availability zones
- NAT Gateways for private subnet internet access
- Internet Gateway for public subnets
- Route tables and network ACLs
- Kubernetes-specific subnet tagging

### EKS Module
Located in `modules/eks/`, this module manages the Kubernetes cluster:
- EKS cluster with configurable version (default: 1.27)
- Node groups in private subnets
- IAM roles and policies
- Security groups
- IRSA (IAM Roles for Service Accounts) setup

### Controllers Module
Located in `modules/eks/controllers/`, this module manages all Kubernetes add-ons:

#### Templates
The `templates/` directory contains Helm values files for all controllers:
- **grafana-values.yaml**: Dashboard configurations, data sources, and persistent storage settings
- **prometheus-values.yaml**: Metrics retention, alerting rules, and resource configurations
- **loki-values.yaml**: Log aggregation settings, retention policies, and storage configurations
- **tempo-values.yaml**: Tracing backend configuration, retention settings, and storage options
- **istiod-values.yaml**: Istio control plane settings, including proxy resources and tracing configuration
- **istio-ingress-values.yaml**: Gateway configurations, load balancer settings, and TLS options
- **kiali-values.yaml**: Service mesh dashboard settings and integration configurations

#### Observability Stack
1. **Grafana** (v6.50.7)
   - Visualization platform
   - Persistent storage
   - Pre-configured datasources
   - LoadBalancer service type

2. **Prometheus** (v45.7.1 - kube-prometheus-stack)
   - Metrics collection and storage
   - AlertManager integration
   - Service monitoring
   - Node and pod metrics
   - 15-day retention

3. **Loki** (v2.9.10)
   - Log aggregation
   - Promtail for log collection
   - Persistent storage
   - Grafana integration

4. **Tempo** (v1.3.1)
   - Distributed tracing
   - Multiple protocol support (Jaeger, Zipkin, OTLP)
   - Grafana integration
   - 7-day retention

#### Service Mesh
1. **Istio** (v1.18.2)
   - Service mesh capabilities
   - Traffic management
   - Security policies
   - Ingress gateway
   - Automatic sidecar injection

2. **Kiali** (v1.73.0)
   - Service mesh visualization
   - Traffic flow graphs
   - Health monitoring
   - Configuration validation

## Backend Configuration

This project uses an AWS S3 bucket as the backend for storing Terraform state files. This provides:
- Secure storage of state files
- State locking to prevent concurrent modifications
- Version history of infrastructure changes
- Team collaboration capabilities

The state files are stored in an S3 bucket with the following configuration:
```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "your-aws-region"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

## Prerequisites

- [Terraform](https://www.terraform.io/) (version 1.0.0 or later)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- AWS account with necessary permissions
- Kubernetes knowledge for working with the deployed resources

## Getting Started

1. Ensure you have the prerequisites installed
2. Configure your AWS credentials
3. Create an S3 bucket and DynamoDB table for state management
4. Update backend configuration with your bucket details
5. Initialize Terraform:
   ```bash
   terraform init
   ```
6. Review the planned changes:
   ```bash
   terraform plan
   ```
7. Apply the changes:
   ```bash
   terraform apply
   ```

## Best Practices

- Always review `terraform plan` output before applying changes
- Use workspaces for managing multiple environments
- Keep sensitive information in variables and use `.tfvars` files
- Regularly commit your Terraform state to version control
- Use consistent naming conventions for resources
- Monitor resource usage and costs
- Regularly update component versions
- Back up critical data

## Contributing

When contributing to this infrastructure code:
1. Create a new branch for your changes
2. Test your changes thoroughly
3. Document any new variables or outputs
4. Update version information in variables.tf
5. Submit a pull request for review

## Security

- Never commit AWS credentials to version control
- Use IAM roles and policies appropriately
- Regularly rotate access keys
- Enable resource tagging for better tracking
- Implement network policies
- Use private subnets for worker nodes
- Enable control plane logging
- Monitor security groups

## Maintenance

Regular maintenance tasks:
- Keep Terraform and provider versions up to date
- Update Kubernetes add-ons to latest stable versions
- Review and clean up unused resources
- Monitor costs and optimize resource usage
- Review logs and metrics
- Check backup status
- Update documentation as infrastructure evolves
- Validate security configurations