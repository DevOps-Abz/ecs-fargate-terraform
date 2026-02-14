variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

#  variable "public_subnet_ids" {
#      description = "List of public subnet IDs"
#      type        = list(string)
#    }

variable "alb_tg_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "alb_load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
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

variable "ecs_task_family" {
  description = "The family name of the ECS task definition"
  type        = string
  default     = "my-task-family"
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
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

variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

