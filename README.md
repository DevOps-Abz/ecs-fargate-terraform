# Production-Ready CI/CD Deployment on AWS ECS Fargate
 ---
A production-grade AWS ECS Fargate deployment featuring containerisation, Infrastructure as Code, GitOps practices, and secure CI/CD automation.

##  Project Overview

This project demonstrates a production-focused AWS deployment that applies DevOps best practices, automates infrastructure end to end, and enforces least-privilege security by design.

## Architecture

------IMPLEMENT FIRST----- 

## What is delpoyed?

an application 

## Key Features & Implementation:

- **A fully automated CI/CD pipeline** using GitHub Actions with OIDC authentication, eliminating the need for long-lived AWS credentials

- **A scalable production-grade deployment** on AWS ECS Fargate

- **Infrastructure as Code (IaC)** implemented using Terraform to provision and manage VPC, IAM, ECS, ALB, and related AWS resources

- **GitOps workflow** where all infra and application changes are version-controlled and applied via Git commits and pull requests

##  Tech Stack

### Cloud & Infrastructure
- **AWS ECS Fargate** – Run containers in a fully managed, serverless environment
- **Amazon ECR** – Centralized and secure repository for Docker images
- **AWS VPC** – Network isolation subnets for public and private resources
- **AWS IAM** – Implemented IAM Role for GitHub Actions authentication via OIDC for secure, short-lived credentials
------IMPLEMENT 1----- **Application Load Balancer (ALB)** – Traffic routing, health checks, and scalability  

### Infrastructure as Code (IaC)
- **Terraform** – Declarative AWS infrastructure as code with automated provisioning
------IMPLEMENT 2-----  **Terraform Modules** – Modular, reusable, and environment-agnostic infrastructure components  

### CI/CD GitOps & DevSecOps
- **GitHub Actions** – Automated build, scan, and deploy pipelines
- **OIDC Authentication** – Authenticate GitHub Actions to access AWS securely with short-lived credentials
- **GitOps Workflow** – Git as the central source of truth for infrastructure and deployments  
------IMPLEMENT 3------ **Trivy** – Vulnerability scanning for containers and filesystems
  
### Containers & Application
- **Docker** – Build and package applications in isolated containers
- **ECS Task Definitions** – Define container runtime using declarative configurations

## Project Structure
------IMPLEMENT 4 REPLACE THIS STRUCTURE BELOW------
```
ecs-fargate-terraform-project
├── docker
│   ├── Dockerfile
│   └── program.py
├── images
├── LICENSE
├── README.md
└── terraform
    ├── ecr.tf
    ├── ecs.tf
    ├── graph.png
    ├── iam.tf
    ├── outputs.tf
    ├── providers.tf
    ├── variables.tf
    └── vpc.tf
```

### Build and push the Docker image: 
    cd docker
docker build -t my-app-repo .
docker tag <image-name>:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/<repository-name>:latest
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/<repository-name>:latest


##  Container Registry (ECR)

Docker images are hosted in Amazon Elastic Container Registry (ECR), enabling secure, scalable storage and access controlled by IAM.

------IMPLEMENT 5 ------- Take a screen shot of [ECR > Private reg > Repository > images ]
!INSERT IMAGE HERE

**GitHub Actions Apply (`deploy.yaml`)**

![Diagram](https://raw.githubusercontent.com/DevOps-Abz/ecs-fargate-terraform/images/git-actions-deploy-workflow.png)

   - Applies approved Terraform changes to provision/update AWS infrastructure  
   - Deploys updated containers to **AWS ECS Fargate**
   
## Challenges & Solutions

**Challenge:**  
Created the GitHub OIDC provider and IAM role in AWS, but forgot to configure the role's trust policy to allow sts:AssumeRoleWithWebIdentity with the correct GitHub repository conditions.

**Solution:**  
Implemented the custom trust policy from GitHub Actions documentation to the IAM role, specifying the OIDC provider as the federated principal and including conditions for the correct audience (sts.amazonaws.com) and subject claim (repository path).

---

**Challenge:**  
Running terraform destroy failed with error "ECR Repository not empty" because the repository contained Docker images that were pushed during deployment, and Terraform requires repositories to be empty before deletion by default.

**Solution:** 
**Added force_delete = true* to the aws_ecr_repository resource in ecr.tf, ran terraform apply to update the resource configuration, then ran terraform destroy to successfully delete the repository with all images.

### Future improvements
- Create separate dev, stage, and prod environments using Terraform workspaces
- Set up better monitoring and alerts with CloudWatch or Prometheus/Grafana dashboards


