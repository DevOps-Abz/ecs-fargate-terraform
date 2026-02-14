output "load_balancer_url" {
  description = "The DNS name / URL of the Application Load Balancer"
  value       = aws_lb.ecs_lb.dns_name
}

output "alb_tg_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.ecs_lb_tg.arn
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.ecs_lb.arn
}