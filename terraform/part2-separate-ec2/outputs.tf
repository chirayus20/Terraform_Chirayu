output "backend_public_ip" {
  description = "Public IP of Flask Backend"
  value       = aws_instance.backend_server.public_ip
}

output "frontend_public_ip" {
  description = "Public IP of Express Frontend"
  value       = aws_instance.frontend_server.public_ip
}
