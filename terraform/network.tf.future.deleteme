resource "aws_vpc" "poc" {
  cidr_block = var.poc_vpc_cidr

  tags = {
    Name = "Cassandra poc Testing VPC"
  }
}

##############################################
# VPN subnet (uses Internet gateway)

resource "aws_internet_gateway" "public-gw" {
  vpc_id = aws_vpc.poc.id
  tags   = {
    Name = "Internet Gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.poc.id
  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public-gw.id
  }
  tags = {
    Name = "Public Route table"
  }
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.poc.id
  cidr_block        = "10.0.255.0/24"
  availability_zone = var.zone

  tags = {
    Name = "Public Subnet"
  }
}

##############################################
# LAN subnet (uses NAT gateway for Internet access)

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.poc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.zone

  tags = {
    Name = "Cassandra Subnet"
  }
}



resource "aws_route_table" "private" {
  vpc_id = aws_vpc.poc.id
  route {
    cidr_block     = "0.0.0.0/0"
    network_interface_id = aws_instance.gateway_server.primary_network_interface_id
  }
  tags = {
    Name = "NAT Route table"
  }
}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private.id
#
}

##############################################
# Security groups

resource "aws_security_group" "all" {
  name   = "axonops-poc-testing-all"
  vpc_id = aws_vpc.poc.id

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

