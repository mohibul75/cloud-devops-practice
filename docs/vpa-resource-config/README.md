# Using Vertical Pod Autoscaler (VPA) for Resource Optimization

> **Note**: This guide is based on practical implementation experience. For a detailed walkthrough and real-world case study, check out my article: [From Trial and Error to Automated Efficiency: Implementing Vertical Pod Autoscaler for Kubernetes](https://medium.com/@mohibulalam75/from-trial-and-error-to-automated-efficiency-implementing-vertical-pod-autoscaler-for-kubernetes-5c8c4b204bc7)

## Overview
The Vertical Pod Autoscaler (VPA) automatically adjusts the CPU and memory resource requests and limits for your Pods. This guide explains how to use VPA's recommendations to optimize your Pod's resource configuration.

## How VPA Works

### Components
1. **Recommender** - Monitors resource utilization and provides recommended values
2. **Updater** - (Disabled in our setup) Would automatically update Pod resources
3. **Admission Controller** - (Disabled in our setup) Would apply recommendations to new Pods

### My Configuration
I use VPA in "recommendation mode" only, which means:
- VPA observes resource usage
- Provides recommendations
- Does NOT automatically update Pods
- Requires manual application of recommendations

> **Implementation Note**: In our Todo application, we've successfully implemented this approach to optimize resource allocation. The configuration shown in the examples below reflects our actual production settings.

## Using VPA Recommendations

### 1. Deploy VPA Resource for Your Workload
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: my-app-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: my-app
  updatePolicy:
    updateMode: "Off"  # Only provide recommendations
```

### 2. Get VPA Recommendations
After deploying the VPA resource, wait for it to gather usage data (typically 1-2 days for accurate recommendations). Then:

```bash
kubectl describe vpa my-app-vpa
```

Look for the "Target" section in the output:
```
Target:
  Container: my-app
    Lower Bound:
      Cpu:     100m
      Memory:  256Mi
    Recommended:
      Cpu:     200m
      Memory:  512Mi
    Upper Bound:
      Cpu:     300m
      Memory:  768Mi
```

### 3. Apply Recommendations

> **Note**: We've successfully used these approaches in our Todo application deployment, with the Conservative Approach proving particularly effective in our development environment.

1. **Conservative Approach** (✨ Our Recommended Approach):
   - Start with values between Lower Bound and Recommended
   - For requests: use Lower Bound
   - For limits: use Recommended or Upper Bound
   ```yaml
   resources:
     requests:
       cpu: "100m"      # Lower Bound
       memory: "256Mi"  # Lower Bound
     limits:
       cpu: "200m"      # Recommended
       memory: "512Mi"  # Recommended
   ```

2. **Balanced Approach**:
   - Use Recommended values for both requests and limits
   ```yaml
   resources:
     requests:
       cpu: "200m"      # Recommended
       memory: "512Mi"  # Recommended
     limits:
       cpu: "300m"      # Upper Bound
       memory: "768Mi"  # Upper Bound
   ```

## Best Practices

1. **Monitoring Period**
   - Allow VPA to observe your application for at least 24-48 hours
   - Consider peak usage times and different load patterns

2. **Regular Review**
   - Review VPA recommendations monthly
   - Update resource configurations quarterly or when significant changes occur

3. **Testing**
   - Always test new resource configurations in non-production environments first
   - Monitor application performance after applying new configurations

4. **Resource Ratios**
   - Keep a reasonable ratio between requests and limits (e.g., 1:1.5 or 1:2)
   - Avoid too wide gaps between requests and limits

## Example VPA Configuration for Todo Application

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: todo-app-vpa
  namespace: dev
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: todo-application-deployment
  updatePolicy:
    updateMode: "Off"
  resourcePolicy:
    containerPolicies:
    - containerName: '*'
      minAllowed:
        cpu: "50m"
        memory: "64Mi"
      maxAllowed:
        cpu: "500m"
        memory: "512Mi"
```

## Troubleshooting

1. **No Recommendations Available**
   - Ensure VPA has been running for at least a few hours
   - Check if metrics-server is properly installed and running
   - Verify the VPA resource is correctly targeting your workload

2. **Unexpected Recommendations**
   - Review historical resource usage patterns
   - Check for any application anomalies during the observation period
   - Consider seasonal or periodic workload patterns

3. **Resource Constraints**
   - Ensure node resources can accommodate the recommended values
   - Check if LimitRange or ResourceQuota are affecting the recommendations

## Additional Resources

- [Kubernetes VPA Documentation](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)
- [VPA Design Proposal](https://github.com/kubernetes/design-proposals-archive/blob/main/autoscaling/vertical-pod-autoscaler.md)
- [Fairwinds VPA Documentation](https://docs.fairwinds.com/goldilocks/installation/)
- [From Trial and Error to Automated Efficiency: Implementing VPA](https://medium.com/@mohibulalam75/from-trial-and-error-to-automated-efficiency-implementing-vertical-pod-autoscaler-for-kubernetes-5c8c4b204bc7) - My detailed implementation guide