resource "aws_eip" "nat" {
  # domain = "vpc"
  tags = {
    Name = "nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-us-east-1a.id

  tags = {
    Name = "nat gw"
  }

  depends_on = [aws_internet_gateway.helios-igw]
}