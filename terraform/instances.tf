# Key Pair
resource "aws_key_pair" "helios_key_pair" {
  public_key = var.helios_ssh_pubkey
  key_name = "Helios Reference Architecture Key Pair"
}

# AWS Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Bastion Gateway Server
resource "aws_instance" "bastion_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  tags = {
    Name        = "Helios Bastion Server"
    Role        = "gateway"
  }
  availability_zone           = var.zone_1
  subnet_id                   = aws_subnet.public-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.all.id]
  private_ip                  = "10.0.1.10"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.helios_key_pair.key_name
  ebs_optimized               = true
  user_data = <<EOF
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get -y install python3-pip
sudo apt-get -y install pipenv
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt update
sudo apt install ansible
  EOF
  source_dest_check = false
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

#resource "aws_eip_association" "gateway_eip_association" {
#  instance_id   = aws_instance.bastion_server.id
#  allocation_id = aws_eip.helios_elastic_ip.id
#}

resource "aws_instance" "cassandra0" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "i4i.2xlarge"
  availability_zone      = var.zone_1
  subnet_id              = aws_subnet.private-subnet-1.id
  vpc_security_group_ids = [aws_security_group.all.id]
  private_ip             = "10.0.3.20"
  key_name               = aws_key_pair.helios_key_pair.key_name
  ebs_optimized          = true
  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 20
    volume_type = "gp3"
  }
  ephemeral_block_device {
    device_name = "/dev/sdc"
    virtual_name = "ephemeral0"
  }
  metadata_options {
    instance_metadata_tags = "enabled"
    http_endpoint          = "enabled"
  }
  tags = {
    Region      = var.region
    Name        = "cassandra-0"
    Disposable  = "false"
    Scalable    = "false"
    Role        = "cassandra"
    Project     = "Helios Reference Architecture"
    ClusterName = "helios"
    DC          = "helios-dc"
    # Rack        = "rack1"
    Seeds       = "10.0.1.20,10.0.1.21"
  }
  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}

resource "aws_instance" "cassandra1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "i4i.2xlarge"
  availability_zone      = var.zone_1
  subnet_id              = aws_subnet.private-subnet-1.id
  vpc_security_group_ids = [aws_security_group.all.id]
  private_ip             = "10.0.3.21"
  key_name               = aws_key_pair.helios_key_pair.key_name
  ebs_optimized          = true
  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 20
    volume_type = "gp3"
  }
  ephemeral_block_device {
    device_name = "/dev/sdc"
    virtual_name = "ephemeral0"
  }
  metadata_options {
    instance_metadata_tags = "enabled"
    http_endpoint          = "enabled"
  }
  tags = {
    Region      = var.region
    Name        = "cassandra-1"
    Disposable  = "false"
    Scalable    = "false"
    Role        = "cassandra"
    Project     = "Helios Reference Architecture"
    ClusterName = "helios"
    DC          = "helios-dc"
    # Rack        = "rack1"
    Seeds       = "10.0.1.20,10.0.1.21"
  }
  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}

