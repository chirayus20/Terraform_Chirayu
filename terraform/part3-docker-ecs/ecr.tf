# ECR repository for Express Frontend
resource "aws_ecr_repository" "frontend" {
  name                 = "part3-frontend-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECR repository for Flask Backend
resource "aws_ecr_repository" "backend" {
  name                 = "part3-backend-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Output frontend repository URL
output "frontend_ecr_url" {
  description = "Frontend ECR repository URL"
  value       = aws_ecr_repository.frontend.repository_url
}

# Output backend repository URL
output "backend_ecr_url" {
  description = "Backend ECR repository URL"
  value       = aws_ecr_repository.backend.repository_url
}