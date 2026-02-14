resource "aws_ecr_repository" "my_repository" {
  name                 = var.repository_name  # Changed from var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  
  lifecycle {
    prevent_destroy = false
  }
  
  force_delete = true
}