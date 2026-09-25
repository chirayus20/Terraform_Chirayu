variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Name of the existing EC2 Key Pair"
}

variable "db_user" {
  type      = string
  default   = "db_admin"
  sensitive = true
}

variable "db_password" {
  type        = string
  description = "MongoDB Admin Password"
  sensitive   = true
}

variable "db_cluster" {
  type    = string
  default = "cluster0.j019kr4.mongodb.net"
}

variable "db_name" {
  type    = string
  default = "aws-mongo-db"
}
