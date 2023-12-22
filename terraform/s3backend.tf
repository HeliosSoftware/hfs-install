# S3 storage and dynamo db for terraform state managment 
terraform {
  backend "s3" {
    bucket         = "helios-terraform-bucket"
    key            = "terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}
