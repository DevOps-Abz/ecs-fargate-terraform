variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "public_subnet_names" {
  description = "Names for public subnets"
  type        = list(string)
  default     = ["public-subnet-1", "public-subnet-2"]
}
variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "private_subnet_names" {
  description = "Names for private subnets"
  type        = list(string)
  default     = ["private-subnet-1", "private-subnet-2"]
}
variable "ecr_repository_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "my-app-repo"
}
variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
  default     = "my-ecs-cluster"
}
variable "ecs_service_name" {
  description = "The name of the ECS service"
  type        = string
  default     = "my-ecs-service"
}
variable "ecs_task_definition_name" {
  description = "The name of the ECS task definition"
  type        = string
  default     = "my-ecs-task"
}
variable "ecs_task_family" {
  description = "The family name of the ECS task definition"
  type        = string
  default = "my-task-family"
}
variable "container_name" {
  description = "The name of the container in the ECS task definition"
  type        = string
  default     = "my-container"
}
variable "container_port" {
  description = "The port on which the container listens"
  type        = number
  default     = 80
}