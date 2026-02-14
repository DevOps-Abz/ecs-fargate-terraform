
resource "aws_ecs_cluster" "my_cluster" {
  name = var.ecs_cluster_name
}
resource "aws_ecs_service" "my_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets = var.private_subnet_ids 
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

   load_balancer {
    target_group_arn = var.alb_tg_arn
    container_name   = var.container_name      # must match task definition
    container_port   = var.container_port      # must match container port
  }

  depends_on = [
    var.alb_load_balancer_arn
  ]
}
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.container_name}"
  retention_in_days = 30
}

data "aws_region" "current" {}

resource "aws_ecs_task_definition" "my_task" {
  family                   = var.ecs_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = var.ecs_task_execution_role_arn
  task_role_arn      = var.ecs_task_execution_role_arn

 container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = "${var.ecr_repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = data.aws_region.current.id
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

