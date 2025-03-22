# Scaling Strategy 

I outline the scaling strategies implemented in my Todo application project, utilizing both Karpenter for node scaling and Horizontal Pod Autoscaler (HPA) for pod scaling.

## Node Scaling with Karpenter

### Overview
I use Karpenter as my node provisioning solution to automatically scale my EKS cluster's compute resources. Karpenter observes incoming pods and makes intelligent decisions about when and how to scale my node infrastructure.

For detailed implementation and configuration of Karpenter with Terraform, please refer to my comprehensive articles:
- [Kubernetes Node Scaling & Provisioning: Karpenter with Terraform](https://mohibulalam75.medium.com/kubernetes-node-scaling-provisioning-karpenter-with-terraform-21bba27e17b8)

Note: The Karpenter configuration is modularized in the `eks/controllers/karpenter` directory and is applied in the infrastructure code.

### Key Features
- Support for both spot and on-demand EC2 instances
- Automatic node provisioning based on pod requirements
- IAM roles and policies for secure operation
- Automatic discovery of subnets and security groups via tags
- Integration with cluster OIDC provider for IAM roles
- EC2 instance profile for node management

### Infrastructure Components
1. **IAM Configuration**:
   - Dedicated controller role with IRSA support
   - Node IAM role with necessary AWS managed policies
   - Instance profile for EC2 instances
   - Fine-grained permissions for EC2 and IAM operations

2. **Resource Discovery**:
   - Subnet auto-discovery using `karpenter.sh/discovery` tags
   - Security group discovery via cluster tags
   - Region and availability zone awareness

## Pod Scaling with HPA

### Overview
I implement Horizontal Pod Autoscaling (HPA) for my Todo application to automatically scale the number of pods based on resource utilization metrics.

### Configuration Details
```yaml
Deployment: todo-application-deployment
Namespace: dev
Scaling Range: 2-10 pods
Resource Thresholds:
- CPU: 90% utilization
- Memory: 90% utilization
```

## Scaling Strategy

### Node Scaling Strategy
1. **Initial Provisioning**:
   - Karpenter monitors for unschedulable pods
   - Provisions nodes based on pod specifications
   - Uses tags for resource discovery

2. **Scaling Up**:
   - Triggered by pending pods
   - Uses IRSA for secure AWS API access
   - Creates nodes in tagged subnets

3. **Scaling Down**:
   - Consolidates workloads efficiently
   - Manages node termination
   - Handles spot instance interruptions

### Pod Scaling Strategy
1. **Scale Out Conditions**:
   - CPU utilization > 90%
   - Memory utilization > 90%
   - Maintains application responsiveness

2. **Scale In Conditions**:
   - Resource utilization below thresholds
   - Minimum 2 replicas for high availability
   - Graceful pod termination

## Monitoring and Alerts

### Key Metrics to Monitor
1. **Node Scaling**:
   - Node provisioning events
   - Spot instance status
   - Resource utilization per node

2. **Pod Scaling**:
   - HPA scaling events
   - Resource utilization metrics
   - Application performance

### Alerts Configuration
- Node provisioning failures
- Persistent unschedulable pods
- Resource utilization thresholds
- Scaling operation failures

## Best Practices

1. **Resource Management**:
   - Accurate resource requests
   - Regular monitoring of utilization
   - Cost-effective instance selection

2. **Scaling Configuration**:
   - High utilization thresholds (90%)
   - Appropriate min/max pod counts
   - Regular threshold reviews

3. **Security**:
   - IRSA for AWS authentication
   - Least privilege IAM policies
   - Secure node bootstrapping

## Troubleshooting

### Common Issues and Solutions

1. **Pods Not Scaling**:
   - I check HPA metrics availability
   - I verify that resource requests are set
   - I check metrics-server functionality

2. **Node Provisioning Issues**:
   - I verify Karpenter permissions
   - I check AWS service quotas
   - I review Karpenter logs

3. **Cost Spikes**:
   - I review scaling patterns
   - I check for unoptimized resource requests
   - I monitor spot instance usage

## Additional Resources

- [Karpenter Documentation](https://karpenter.sh/)
- [Kubernetes HPA Documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)