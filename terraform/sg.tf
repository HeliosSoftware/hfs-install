resource "aws_security_group" "allow_outbound_all" {
  name          = "Helios Security Group - Allow Outbound All"
  description   = "Allow all traffic outbound"
  vpc_id        = aws_vpc.helios-vpc.id

  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_outbound_all"
  }
}

resource "aws_security_group" "allow_tls" {
  name          = "Helios Security Group - Allow TLS"
  description   = "Allow TLS inbound traffic"
  vpc_id        = aws_vpc.helios-vpc.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group" "allow_public_subnet_all" {
  name          = "Helios Security Group - Allow Public Subnet All"
  description   = "Allow all traffic on the public subnet for EKS and HFS"
  vpc_id        = aws_vpc.helios-vpc.id

  # Allow Any from within the public subnets
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_1_cidr, var.public_subnet_2_cidr]
  }

  tags = {
    Name = "allow_public_subnet_all"
  }
}

resource "aws_security_group" "allow_private_subnet_all" {
  name          = "Helios Security Group - Allow Private Subnet All"
  description   = "Allow all traffic on the private subnet for Cassandra nodes"
  vpc_id        = aws_vpc.helios-vpc.id

  # Allow Any from within the private subnets
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_1_cidr, var.private_subnet_2_cidr]
  }

  tags = {
    Name = "allow_private_subnet_all"
  }
}

resource "aws_security_group" "allow_cassandra" {
  name          = "Helios Security Group - Allow Cassandra"
  description   = "Allow Cassandra inbound traffic"
  vpc_id        = aws_vpc.helios-vpc.id

  # Allow 9042 into the private subnets
  ingress {
    from_port   = 9042
    to_port     = 9042
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_1_cidr, var.public_subnet_2_cidr]
  }

  tags = {
    Name = "allow_tls"
  }
}
