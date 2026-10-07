# AWS Region configuration
variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS Region for deployment"
}

# Database User for MongoDB
variable "db_user" {
  type      = string
  default   = "db_admin"
  sensitive = true
}

# Database Password for MongoDB
variable "db_password" {
  type        = string
  description = "MongoDB Admin Password"
  sensitive   = true
}

# Database Cluster Host URL
variable "db_cluster" {
  type    = string
  default = "cluster0.j019kr4.mongodb.net"
}

# Database Name
variable "db_name" {
  type    = string
  default = "aws-mongo-db"
}
