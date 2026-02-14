provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # bucket needs to be created manualy, terraform won't do it.
  # below (backend "s3" ) tells terraform NOT to store state on my laptop — store it in AWS S3.”
  backend "s3" {
    bucket       = "abz-terraform-state-bucket"
    key          = "terraform/state/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true # Encrypts the state file at rest
    use_lockfile = true # Prevents two people running Terraform at the same time.
  }
}