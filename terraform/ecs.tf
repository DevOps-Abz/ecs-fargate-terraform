# Resource names here are for terraform interal use only. Different to the variable values you assign e.g "my-ecs-cluster"

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
    subnets          = [aws_subnet.public.id]  # Or use private subnet if you prefer
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }
}
resource "aws_ecs_task_definition" "my_task" {
  family                   = var.ecs_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_execution_role.arn

 container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = "${aws_ecr_repository.my_repository.repository_url}:latest"
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
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg"
  description = "Allow inbound traffic for ECS tasks"
  vpc_id      = aws_vpc.main.id

   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    # Restrict ingress tightly, allow egress broadly. Allow all outbound traffic (DNS,UDP,TCP,443,80), on all ports,
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/my-container"
  retention_in_days = 30
}
