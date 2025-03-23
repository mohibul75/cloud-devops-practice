# Infrastructure as Code (IaC)

This repository contains Terraform configurations for managing AWS infrastructure, focusing on a production-ready EKS cluster with comprehensive monitoring and observability capabilities.

## Architecture Overview

The infrastructure is built on AWS using a modular approach:
- **Networking**: VPC with public/private subnets across availability zones
- **Compute**: EKS cluster with managed node groups and autoscaling
- **Observability**: Complete monitoring stack with Grafana, Prometheus, Loki, and Tempo
- **Service Mesh**: Istio for traffic management and service communication

## Directory Structure

```
iac/
├── dev-backend.hcl            # Backend configuration for dev environment
├── modules/                   # Reusable Terraform modules
│   ├── vpc/                  # VPC and networking configuration
│   │   ├── main.tf          # VPC resources
│   │   ├── variables.tf     # Input variables
│   │   └── outputs.tf       # Output values
│   │
│   └── eks/                 # EKS cluster configuration
│       ├── 00-init.tf      # Provider and initial setup
│       ├── add-ons.tf      # EKS add-ons configuration
│       ├── main.tf         # EKS cluster resources
│       ├── sg.tf          # Security group configurations
│       ├── variables.tf    # Input variables
│       ├── outputs.tf      # Output values
│       └── controllers/    # Kubernetes controllers
│           ├── grafana/    # Grafana deployment
│           ├── istio/      # Service mesh configuration
│           ├── karpenter/  # Node autoscaling
│           ├── loki/       # Logging stack
│           ├── prometheus/ # Monitoring stack
│           ├── tempo/      # Distributed tracing
│           └── vpa/        # Vertical Pod Autoscaler
├── main.tf                  # Main Terraform configuration
└── variables.tf             # Input variables
```

## Infrastructure Components

### VPC Configuration
- **CIDR Block**: 10.0.0.0/16
- **Subnets**: 
  - Public subnets for NAT Gateways and load balancers
  - Private subnets for EKS nodes and pods
- **Networking**:
  - Internet Gateway for public access
  - NAT Gateways for private subnet connectivity
  - Route tables for traffic management

### EKS Cluster
- **Version**: 1.27
- **Node Groups**:
  - 2 worker nodes in private subnets
  - Instance type: t3.medium
- **Autoscaling**:
  - Karpenter for node autoscaling
  - Horizontal Pod Autoscaler for workloads
  - Vertical Pod Autoscaler for resource optimization

### Observability Stack
1. **Grafana**
   - Deployment: Helm chart
   - Persistence: EBS volumes
   - Default dashboards for cluster monitoring

2. **Prometheus**
   - Deployment: Helm chart
   - Storage: EBS volumes
   - Service monitors for key metrics
   - Node and pod metrics collection

3. **Loki**
   - Deployment: Helm chart
   - Storage: S3 bucket
   - Log aggregation from all pods
   - Promtail for log collection

4. **Tempo**
   - Deployment: Helm chart
   - Storage: S3 bucket
   - Distributed tracing support
   - Integration with Grafana

### Service Mesh
**Istio**
- **Components**:
  - Istiod for control plane
  - Ingress Gateway for external traffic
  - Sidecar injection for service mesh
- **Features**:
  - Traffic management
  - Service discovery
  - Load balancing

## Prerequisites

1. **Tools**
   - Terraform >= 1.0.0
   - AWS CLI configured
   - kubectl

2. **AWS Account**
   - Required permissions for EKS, VPC, IAM
   - Sufficient quotas for resources

## Deployment Guide

1. **Configure AWS Credentials**
   ```bash
   aws configure
   # Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
   ```

2. **Initialize Terraform**
   ```bash
   terraform init -backend-config=dev-backend.hcl
   ```

3. **Review Configuration**
   ```bash
   terraform plan -var-file=terraform.tfvars
   ```

4. **Apply Changes**
   ```bash
   terraform apply -var-file=terraform.tfvars
   ```

5. **Configure kubectl**
   ```bash
   aws eks update-kubeconfig --name cluster-name --region region
   ```

## Security Implementation

1. **Network Security**
   - Private subnets for worker nodes
   - Security groups for cluster access
   - Network policies for pod communication

2. **Access Control**
   - IAM roles for service accounts (IRSA)
   - RBAC for Kubernetes resources
   - AWS Secrets Manager for sensitive data

3. **Monitoring**
   - Control plane logging enabled
   - Audit logging for cluster events
   - Security group monitoring

## Best Practices

1. **Infrastructure Management**
   - Use terraform plan before applying changes
   - Store state files in S3 with versioning
   - Use consistent tagging for resources

2. **Security**
   - Regularly rotate credentials
   - Monitor security group changes
   - Keep EKS version updated

3. **Cost Optimization**
   - Use node autoscaling
   - Monitor resource utilization
   - Clean up unused resources

## Known Limitations

> **Note**: The following features are not implemented due to time constraints:
- SSL/TLS certificates for ingress
- Advanced Grafana dashboards
- Custom alerting rules
- Backup and disaster recovery