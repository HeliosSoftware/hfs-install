##################################################################
#
# Instances
#


resource "aws_key_pair" "automation" {
  public_key = var.automation_ssh_pubkey
  key_name = "poc"
}



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

resource "aws_instance" "gateway_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name        = "cassandra poc gateway"
    Role        = "gateway"
  }

  availability_zone           = var.zone
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.all.id]
  private_ip                  = "10.0.255.10"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.automation.key_name
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


resource "aws_eip" "gateway" {
  vpc = true
}

resource "aws_eip_association" "gateway_eip_association" {
  instance_id   = aws_instance.gateway_server.id
  allocation_id = aws_eip.gateway.id
}



resource "aws_instance" "cassandra0" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "i4i.2xlarge"
  
  availability_zone      = var.zone
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.all.id]
  private_ip             = "10.0.1.20"
  key_name               = aws_key_pair.automation.key_name
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
    Name        = "poc axonops cassandra-000"
    Disposable  = "false"
    Scalable    = "false"
    Role        = "cassandra"
    Project     = "axonops-poc-testing"
    ClusterName = "axonops"
    DC          = "poc"
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
  
  availability_zone      = var.zone
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.all.id]
  private_ip             = "10.0.1.21"
  key_name               = aws_key_pair.automation.key_name
  ebs_optimized          = true

  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 20
    volume_type = "gp3"
  }

  metadata_options {
    instance_metadata_tags = "enabled"
    http_endpoint          = "enabled"
  }

  tags = {
    Region      = var.region
    Name        = "poc axonops cassandra-001"
    Disposable  = "false"
    Scalable    = "false"
    Role        = "cassandra"
    Project     = "axonops-poc-testing"
    ClusterName = "axonops"
    DC          = "poc"
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


resource "aws_instance" "cassandra2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "i4i.2xlarge"
  
  availability_zone      = var.zone
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.all.id]
  private_ip             = "10.0.1.22"
  key_name               = aws_key_pair.automation.key_name
  ebs_optimized          = true

  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 20
    volume_type = "gp3"
  }

  metadata_options {
    instance_metadata_tags = "enabled"
    http_endpoint          = "enabled"
  }

  tags = {
    Region      = var.region
    Name        = "poc axonops cassandra-002"
    Disposable  = "false"
    Scalable    = "false"
    Role        = "cassandra"
    Project     = "axonops-poc-testing"
    ClusterName = "axonops"
    DC          = "poc"
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

