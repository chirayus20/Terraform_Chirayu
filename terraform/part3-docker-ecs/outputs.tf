# Load Balancer DNS Name to access the application
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.part3_alb.dns_name
}

# Frontend Application URL
output "frontend_url" {
  description = "URL to access Express Frontend"
  value       = "http://${aws_lb.part3_alb.dns_name}:8000"
}

# Backend Application URL
output "backend_url" {
  description = "URL to access Flask Backend"
  value       = "http://${aws_lb.part3_alb.dns_name}:9000"
}
