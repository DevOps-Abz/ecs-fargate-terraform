# Production-Ready CI/CD Deployment on AWS ECS Fargate

A production-grade AWS ECS Fargate deployment featuring containerisation, Infrastructure as Code, GitOps practices, and secure CI/CD automation.

---

##  Project Overview

This project demonstrates a production-focused AWS deployment that applies DevOps best practices, automates infrastructure end to end, and enforces least-privilege security by design.

---

## Architecture

![Diagram](https://github.com/DevOps-Abz/ecs-fargate-terraform/blob/main/images/main-diagram.png)

---

## What is delpoyed?

A Python Application 

---

## Key Features & Implementation:

- **A fully automated CI/CD pipeline** using GitHub Actions with OIDC authentication, eliminating the need for long-lived AWS credentials

- **A scalable production-grade deployment** on AWS ECS Fargate

- **Infrastructure as Code (IaC)** implemented using Terraform to provision and manage VPC, IAM, ECS, ALB, and related AWS resources

- **GitOps workflow** where all infra and application changes are version-controlled and applied via Git commits and pull requests

---

##  Tech Stack

### Cloud & Infrastructure
- **AWS ECS Fargate** – Run containers in a fully managed, serverless environment

- **Amazon ECR** – Centralized and secure repository for Docker images

- **AWS VPC** – Network isolation subnets for public and private resources

- **AWS IAM** – Implemented IAM Role for GitHub Actions authentication via OIDC for secure, short-lived credentials

- **Application Load Balancer (ALB)** – Traffic routing, health checks, and scalability
 
---

### Infrastructure as Code (IaC)
- **Terraform** – Declarative AWS infrastructure as code with automated provisioning

---
  
### CI/CD GitOps & DevSecOps
- **GitHub Actions** – Automated build, scan, and deploy pipelines
- **OIDC Authentication** – Authenticate GitHub Actions to access AWS securely with short-lived credentials
- **GitOps Workflow** – Git as the central source of truth for infrastructure and deployments  

---

### Containers & Application
- **Docker** – Build and package applications in isolated containers
- **ECS Task Definitions** – Define container runtime using declarative configurations

---

## Project Structure
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
    ├── iam.tf
    ├── outputs.tf
    ├── providers.tf
    ├── variables.tf
    └── vpc.tf
```

---

## Build and Push Docker Image to ECR

```bash
# Build the Docker image locally
docker build -t my-app-repo:latest .

# Tag the image for Amazon ECR
docker tag my-app-repo:latest <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/my-app-repo:latest

# Push the image to ECR
docker push <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/my-app-repo:latest
```

---

##  Elastic Container Registry

Amazon Elastic Container Registry (ECR) is used to securely store Docker images at scale, with access controlled via IAM.

![Diagram](https://github.com/DevOps-Abz/ecs-fargate-terraform/blob/main/images/ecr.png)

Docker images are stored in Amazon Elastic Container Registry, providing secure, scalable image storage with IAM-based authentication.

---

**GitHub Actions Apply (`deploy.yaml`)**

![Diagram](https://github.com/DevOps-Abz/ecs-fargate-terraform/blob/main/images/git-actions-deploy-workflow.png)

   - Applies approved Terraform changes to provision/update AWS infrastructure  
   - Deploys updated containers to **AWS ECS Fargate**

---

## Security & Compliance by Design

- **OIDC authentication** integrates GitHub Actions with AWS IAM using short-lived credentials instead of stored access keys.

- **Least-privilege IAM architecture** by design to ensure CI/CD workflows and ECS workloads only have the permissions they require. 

- **GitHub Secrets Management** to avoid hard-coded credentials in code or pipelines.

- **Isolated networking architecture** using public and private subnets, with ingress traffic governed by an Application Load Balancer.

- **Auditability & Change Management** using GitOps workflows, to provide auditable history of infrastructure and to ensure all deployment changes are version-controlled in Git.

---

## Challenges & Solutions

**Challenge:**  
When deploying via GitHub Actions, the pipeline got stuck at the AWS credentials configuration stage due to an IAM OIDC trust policy error (sts:AssumeRoleWithWebIdentity).

**Solution:**  
To fix this issue, I referred to the GitHub Actions official Docs. I had to specify the IAM Role OIDC provider as the federated principle to include conditions for the correct audience.  This issue usually occurs when the trust policy conditions (audience or sub repository claim) are missing or misconfigured.

---

**Challenge:**  
Running terraform destroy failed with error "ECR Repository not empty" because the repository contained Docker images that were pushed during deployment, and Terraform requires repositories to be empty before deletion by default.

**Solution:** 
**Added force_delete = true* to the aws_ecr_repository resource in ecr.tf, ran terraform apply to update the resource configuration, then ran terraform destroy to successfully delete the repository with all images.

---

**Challenge:**  
Humans are prone to forget. While testing the deployment pipeline, I forgot to destroy the infrastructure after testing the deployment, which can easily lead to unnecessary cloud costs. 

**Solution:** 
I added a timed delay in the deploy.yaml script in order for terraform to destroy infrastructure if forgotten (after testing). This is useful for testing purpose, but never for production environment.

---

### Future improvements
- Use Terraform Modules for Modular, reusable, and environment-agnostic infrastructure components  
- Set up better monitoring and alerts with CloudWatch or Prometheus/Grafana dashboards
- Incorporate Trivy for Vulnerability scanning for containers and filesystems  
- Create separate dev, stage, and prod environments using Terraform workspaces

### Key Takeaways 

**Unintended Costs from Git Pushes:** 
Making any change to the repo can trigger GitHub Actions if the workflow runs on every push, which may deploy infrastructure unnecessarily. Best practice is to limit the workflow to infra-related files only, so you can safely push docs or README updates without triggering deployments.  

```bash
on:
  push:
    branches: [ main ]
    paths:
     - "terraform/**"                      # Trigger deploy for Terraform changes
      - "docker/**"                        # Trigger deploy for Docker changes
      - ".github/workflows/deploy.yaml"    # Trigger deploy if workflow itself changes
      - "!README.md"                       # Ignore README changes
      - "!images/**"                       # Ignore changes in images folder
```

**Handling Terraform State Locks Safely:**
Never cancel a GitHub Actions workflow during terraform apply. Terraform uses a state lock for remote states (e.g., S3), which won’t release automatically. If interrupted, terraform destroy will fail until you run terraform force-unlock <LOCK_ID>. Always let workflows finish or use a smaller test environment.

