terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Custom VPC
resource "aws_vpc" "app_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "part2-vpc"
  }
}

# 2. Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "part2-public-subnet"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "part2-igw"
  }
}

# 4. Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "part2-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 5. Security Group for Flask Backend (Port 9000)
resource "aws_security_group" "backend_sg" {
  name        = "part2-backend-sg"
  description = "Allow inbound on 9000 and 22"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "part2-backend-sg"
  }
}

# 6. Security Group for Express Frontend (Port 8000)
resource "aws_security_group" "frontend_sg" {
  name        = "part2-frontend-sg"
  description = "Allow inbound on 8000 and 22"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "part2-frontend-sg"
  }
}

# AMI Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# 7. Flask Backend Server
resource "aws_instance" "backend_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y git python3-pip

    cd /home/ubuntu
    git clone https://github.com/chirayus20/Terraform_Chirayu.git app

    cat << ENVFILE > /home/ubuntu/app/backend/.env
    DB_USER=${var.db_user}
    DB_PASSWORD=${var.db_password}
    DB_CLUSTER=${var.db_cluster}
    DB_NAME=${var.db_name}
ENVFILE

    chown -R ubuntu:ubuntu /home/ubuntu/app
    chmod 600 /home/ubuntu/app/backend/.env

    cd /home/ubuntu/app/backend
    pip3 install -r requirements.txt
    sudo -u ubuntu nohup python3 app.py > backend.log 2>&1 &
  EOF

  tags = {
    Name = "Flask-Backend-Server"
  }
}

# 8. Express Frontend Server
resource "aws_instance" "frontend_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

 user_data = <<-EOF
    #!/bin/bash
    # Update system packages and install required tools
    apt-get update -y
    apt-get install -y git nodejs npm

    # Clone the project repository into the ubuntu user home directory
    cd /home/ubuntu
    git clone https://github.com/chirayus20/Terraform_Chirayu.git app

    # Create the frontend environment file and inject the backend private IP on port 9000
    cat << 'ENVFILE' > /home/ubuntu/app/frontend/.env
    BACKEND_URL=http://${aws_instance.backend_server.private_ip}:9000
    ENVFILE

    # Set proper permissions for the ubuntu user
    chown -R ubuntu:ubuntu /home/ubuntu/app

    # Install dependencies and start the Express frontend application on port 8000
    cd /home/ubuntu/app/frontend
    sudo -u ubuntu npm install
    sudo -u ubuntu BACKEND_URL=http://${aws_instance.backend_server.private_ip}:9000 nohup npm start > frontend.log 2>&1 &
  EOF

  tags = {
    Name = "Express-Frontend-Server"
  }
}