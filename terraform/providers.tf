terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.38"
    }
  }
}

provider "aws" {
  // Credentials from environment
  region = var.region
  default_tags {
    tags = {
      Environment = "Helios Cassandra PoC"
    }
  }
}
