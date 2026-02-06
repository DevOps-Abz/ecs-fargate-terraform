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
    subnets = aws_subnet.public[*].id # Or use private subnet if you prefer
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

   load_balancer {
    target_group_arn = aws_lb_target_group.ecs_lb_tg.arn
    container_name   = var.container_name      # must match task definition
    container_port   = var.container_port      # must match container port
  }

  depends_on = [
    aws_lb_listener.front_end
  ]
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
resource "aws_lb" "ecs_lb" {
  name               = "ecs-lb"
  internal           = false
  load_balancer_type = "application"
   subnets = aws_subnet.public[*].id
  security_groups    = [aws_security_group.ecs_tasks.id]
}
resource "aws_lb_target_group" "ecs_lb_tg" {
  name        = "ecs-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_lb_tg.arn
  }

}
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/my-container"
  retention_in_days = 30
}
