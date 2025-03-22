# CI/CD Workflows Documentation

This directory contains documentation for all CI/CD pipelines and workflows in the project.

## Directory Structure

```
workflows/
├── application/         # Contains documentation for application deployment pipeline
│                       # Includes Docker build, push, and Kubernetes deployment
│
├── data-persistent/     # Contains documentation for MongoDB StatefulSet deployment
│                       # Includes storage class and persistent volume management
│
└── infrastructure/      # Contains documentation for Terraform-based infrastructure
                        # Includes EKS cluster, VPC, and IAM configuration
```


## Getting Started

1. **Infrastructure Setup**
   ```bash
   cd iac/
   # Follow infrastructure/README.md
   ```

2. **Database Setup**
   ```bash
   cd kube/
   # Follow data-persistent/README.md
   ```

3. **Application Deployment**
   ```bash
   cd app/
   # Follow application/README.md
   ```

## Pipeline Triggers

| Pipeline | Trigger Paths | Branches |
|----------|--------------|-----------|
| Infrastructure | `iac/**` | main, feature/*, fix/* |
| Data | `kube/mongodb-*` | main, feature/*, fix/* |
| Application | `app/**` | main, feature/*, fix/* |