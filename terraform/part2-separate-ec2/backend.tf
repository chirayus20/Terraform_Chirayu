# Configure S3 backend with DynamoDB locking for Part 2
terraform {
  backend "s3" {
    bucket         = "chirayu-terraform-state-bucket"
    key            = "part2/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}