# DevOps Practice Project

This project demonstrates a comprehensive DevOps implementation challenge, showcasing modern cloud-native practices and infrastructure automation.

## Technology Stack

- **Infrastructure**: AWS cloud infrastructure orchestrated through Terraform, managing both AWS resources and Kubernetes objects
- **CI/CD**: Automated pipelines implemented with GitHub Actions for continuous integration and deployment
- **Monitoring**: Complete observability stack including:
  - Grafana for visualization
  - Prometheus for metrics
  - Loki for log aggregation
  - Tempo for distributed tracing
  All components are deployed via Helm charts and managed through Terraform

> **Note**: Due to time constraints, the monitoring stack implementation is currently basic. While all components are functional and properly integrated, advanced features like custom dashboards and alerting rules can be introduced.

## Development Practices

The project follows industry-standard software development lifecycle (SDLC) practices:
- Issue tracking through GitHub Issues
- Version control with Git
- Standardized commit message format
- Trunk-based development strategy

Comprehensive documentation for each component is available in the [docs](docs/) directory.

## Directory Structure

```
.
├── .github/
│   └── workflows/                    # CI/CD Pipeline configurations
│       ├── application-workflow.yml  # Application deployment pipeline
│       ├── data-workflow.yml         # Data persistence pipeline
│       └── infrastructure-workflow.yml # Infrastructure pipeline
├── docs/
│   ├── branching-strategy/          # Git branching strategy docs
│   │   └── README.md
│   └── workflows/                   # Pipeline documentation
│       ├── application/             # Application pipeline docs
│       │   └── README.md
│       ├── data-persistent/         # Data pipeline docs
│       │   └── README.md
│       ├── infrastructure/          # Infrastructure pipeline docs
│       │   └── README.md
│       └── README.md               # Overview of all pipelines
├── iac/                            # Infrastructure as Code
│   ├── modules/                    # Terraform modules
│   │   ├── eks/                   # EKS cluster configuration
│   │   │   ├── main.tf
│   │   │   └── variables.tf
│   │   └── vpc/                   # VPC configuration
│   │       ├── main.tf
│   │       └── variables.tf
│   ├── main.tf                    # Main Terraform configuration
│   └── variables.tf               # Terraform variables
└── kube/                          # Kubernetes manifests
    ├── mongodb-statefulset.yml    # MongoDB StatefulSet config
    └── storage-class.yml          # Storage class definition
```

## Directory Descriptions

### Infrastructure as Code (`iac/`)
Contains Terraform configurations for AWS infrastructure:
- EKS cluster setup
- VPC and networking
- IAM roles and policies
- Monitoring stack deployment

### Kubernetes Manifests (`kube/`)
Contains Kubernetes resource definitions:
- MongoDB StatefulSet configuration
- Storage class definitions
- Service configurations

### Documentation (`docs/`)
Project documentation organized by component:
- Branching strategy
- Pipeline workflows
  - Application deployment
  - Data persistence
  - Infrastructure management

### GitHub Workflows (`.github/workflows/`)
CI/CD pipeline configurations:
- Application deployment workflow
- Data persistence workflow
- Infrastructure deployment workflow

## Getting Started

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/assessment.git
   ```

2. Set up development environment
   ```bash
   cd assessment
   # Install required tools
   make setup
   ```

3. Create new feature branch
   ```bash
   git checkout -b feature/123-new-feature
   ```

4. Make changes and commit
   ```bash
   git commit -m "feat(scope): description"
   ```

5. Push changes and create PR
   ```bash
   git push origin feature/123-new-feature
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](/LICENSE) file for details.


## Support

For support and questions:
- Create an issue
- Check documentation