# VPC Creation
resource "aws_vpc" "helios-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "helios-vpc"
  }
}
