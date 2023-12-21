# VPC Creation
resource "aws_vpc" "helios-vpc-1" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "helios-vpc-1"
  }
}

# Public Subnet creation 
resource "aws_subnet" "public-us-east-1a" {
  vpc_id                  = aws_vpc.helios-vpc-1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-us-east-1a"
  }
}

resource "aws_subnet" "public-us-east-1c" {
  vpc_id                  = aws_vpc.helios-vpc-1.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-us-east-1c"
  }
}

# Private Subnet creation 
resource "aws_subnet" "private-us-east-1a" {
  vpc_id                  = aws_vpc.helios-vpc-1.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-us-east-1a"
  }
}

resource "aws_subnet" "private-us-east-1c" {
  vpc_id                  = aws_vpc.helios-vpc-1.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-us-east-1c"
  }
}


# IGW creation for VPC
resource "aws_internet_gateway" "helios-igw" {
  vpc_id = aws_vpc.helios-vpc-1.id
  tags = {
    Name = "helios-igw"
  }
  depends_on = [aws_vpc.helios-vpc-1]
}

# Route table for Public Subnet
resource "aws_route_table" "helios-rt-public" {
  vpc_id = aws_vpc.helios-vpc-1.id
  tags = {
    Name = "helios-rt-public"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.helios-igw.id
  }
}

# Route table for Private Subnet
resource "aws_route_table" "helios-rt-private" {
  vpc_id = aws_vpc.helios-vpc-1.id
  tags = {
    Name = "helios-rt-private"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

# Route Table association for Public Subnet
resource "aws_route_table_association" "subnet_association-pub1a" {
  subnet_id      = aws_subnet.public-us-east-1a.id
  route_table_id = aws_route_table.helios-rt-public.id
}

resource "aws_route_table_association" "subnet_association-pub1c" {
  subnet_id      = aws_subnet.public-us-east-1c.id
  route_table_id = aws_route_table.helios-rt-public.id
}

# Route Table association for Private Subnets
resource "aws_route_table_association" "subnet_association-pr1a" {
  subnet_id      = aws_subnet.private-us-east-1a.id
  route_table_id = aws_route_table.helios-rt-private.id
}

resource "aws_route_table_association" "subnet_association-pr1c" {
  subnet_id      = aws_subnet.private-us-east-1c.id
  route_table_id = aws_route_table.helios-rt-private.id
}