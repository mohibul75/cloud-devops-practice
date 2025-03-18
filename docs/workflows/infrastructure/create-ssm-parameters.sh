#!/bin/bash

# Example script to initialize AWS Parameter Store with required parameters for EKS infrastructure deployment
# These parameters are used by the GitHub Actions pipeline to provision and manage the EKS cluster and its components

# Set AWS Region
AWS_REGION="ap-southeast-1"

# Basic Configuration Parameters
aws ssm put-parameter \
  --name "/eks/iac/dev/project" \
  --value "infra-practice" \
  --type "String" \
  --overwrite

aws ssm put-parameter \
  --name "/eks/iac/dev/environment" \
  --value "dev" \
  --type "String" \
  --overwrite

aws ssm put-parameter \
  --name "/eks/iac/dev/vpc_cidr" \
  --value "10.0.0.0/16" \
  --type "String" \
  --overwrite

aws ssm put-parameter \
  --name "/eks/iac/dev/cluster_version" \
  --value "1.31" \
  --type "String" \
  --overwrite

# Subnet Configuration
aws ssm put-parameter \
  --name "/eks/iac/dev/public_subnets" \
  --value '["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]' \
  --type "String" \
  --overwrite

aws ssm put-parameter \
  --name "/eks/iac/dev/private_subnets" \
  --value '["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]' \
  --type "String" \
  --overwrite

# Node Groups Configuration
NODE_GROUPS_JSON='{
  "default": {
    "instance_types": ["t3.small"],
    "capacity_type": "ON_DEMAND",
    "scaling_config": {
      "desired_size": 1,
      "max_size": 2,
      "min_size": 1
    },
    "update_config": {
      "max_unavailable": 1
    }
  }
}'

aws ssm put-parameter \
  --name "/eks/iac/dev/node_groups" \
  --value "$NODE_GROUPS_JSON" \
  --type "String" \
  --overwrite

# Tags Configuration
TAGS_JSON='{
  "Environment": "dev",
  "Project": "infra-practice",
  "ManagedBy": "Terraform",
  "Owner": "DevOps"
}'

aws ssm put-parameter \
  --name "/eks/iac/dev/tags" \
  --value "$TAGS_JSON" \
  --type "String" \
  --overwrite

echo "All parameters have been created/updated in AWS Parameter Store"
