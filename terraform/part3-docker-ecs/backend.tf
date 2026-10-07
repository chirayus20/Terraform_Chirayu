# Configure S3 backend with DynamoDB locking for Part 3
terraform {
  backend "s3" {
    bucket         = "chirayu-terraform-state-bucket"
    key            = "part3/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}