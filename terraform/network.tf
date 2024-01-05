# Public Subnet creation
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.helios-vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.zone_1
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.helios-vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.zone_2
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Private Subnet creation
resource "aws_subnet" "private-subnet-1" {
  vpc_id                  = aws_vpc.helios-vpc.id
  cidr_block              = var.private_subnet_1_cidr
  availability_zone       = var.zone_1
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id                  = aws_vpc.helios-vpc.id
  cidr_block              = var.private_subnet_2_cidr
  availability_zone       = var.zone_2
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-2"
  }
}


# IGW creation for VPC
resource "aws_internet_gateway" "helios-igw" {
  vpc_id = aws_vpc.helios-vpc.id
  depends_on = [aws_vpc.helios-vpc]
  tags = {
    Name = "helios-igw"
  }
}

# Route table for Public Subnet
resource "aws_route_table" "helios-rt-public" {
  vpc_id = aws_vpc.helios-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.helios-igw.id
  }
  tags = {
    Name = "helios-rt-public"
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name = "NAT Gateway for Internet access"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.helios-igw]
}

# Route table for Private Subnet
resource "aws_route_table" "helios-rt-private" {
  vpc_id = aws_vpc.helios-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "helios-rt-private"
  }
}

# Route Table association for Public Subnet
resource "aws_route_table_association" "subnet_association-public-subnet-1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.helios-rt-public.id
}

resource "aws_route_table_association" "subnet_association-public-subnet-2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.helios-rt-public.id
}

# Route Table association for Private Subnets
resource "aws_route_table_association" "subnet_association-private-1" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.helios-rt-private.id
}

resource "aws_route_table_association" "subnet_association-private-2" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.helios-rt-private.id
}

resource "aws_security_group" "all" {
  name   = "Helios Security Group - All"
  vpc_id = aws_vpc.helios-vpc.id

  # Outbound access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from within the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP within the VPC
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Allow Any from within the VPC
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

}