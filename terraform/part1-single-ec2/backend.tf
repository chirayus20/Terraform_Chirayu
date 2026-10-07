# Configure S3 backend with DynamoDB locking for Part 1
terraform {
  backend "s3" {
    bucket         = "chirayu-terraform-state-bucket"
    key            = "part1/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}