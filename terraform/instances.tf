# Key Pair
resource "aws_key_pair" "helios_local_key_pair" {
  key_name = "Helios Reference Architecture Key Pair - Local"
  public_key = file(var.local_ssh_public_key)
}

resource "aws_key_pair" "helios_generated_key_pair" {
  key_name = "Helios Reference Architecture Key Pair - Generated"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
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
    Environment = var.ENVIRONMENT
  }
  availability_zone           = var.zone_1
  subnet_id                   = aws_subnet.public-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id]
  private_ip                  = "10.0.1.10"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.helios_local_key_pair.key_name
  ebs_optimized               = true
  user_data = <<EOF
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get -y install python3-pip
sudo apt-get -y install pipenv
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt --yes update
sudo apt --yes install ansible
sudo pip3 install boto3
sudo pip3 install ansible
echo '${tls_private_key.ssh.private_key_openssh}' >> /home/ubuntu/.ssh/id_ed25519
echo '${tls_private_key.ssh.public_key_openssh}' >> /home/ubuntu/.ssh/id_ed25519.pub
chown ubuntu:ubuntu /home/ubuntu/.ssh/id_ed25519
chown ubuntu:ubuntu /home/ubuntu/.ssh/id_ed25519.pub
chmod 400 /home/ubuntu/.ssh/id_ed25519
  EOF
  source_dest_check = false
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

resource "aws_instance" "cassandra_0" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "i4i.2xlarge"
  availability_zone      = var.zone_1
  subnet_id              = aws_subnet.private-subnet-1.id
  vpc_security_group_ids = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id, aws_security_group.allow_private_subnet_all.id]
  private_ip             = "10.0.3.20"
  key_name               = aws_key_pair.helios_generated_key_pair.key_name
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
    ClusterName = var.CASSANDRA_CLUSTER_NAME
    DC          = "helios-dc"
    # Rack        = "rack1"
    Seeds       = "10.0.3.20"
    Environment = var.ENVIRONMENT
  }
  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}

resource "aws_instance" "cassandra_1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "i4i.2xlarge"
  availability_zone      = var.zone_1
  subnet_id              = aws_subnet.private-subnet-1.id
  vpc_security_group_ids = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id, aws_security_group.allow_private_subnet_all.id]
  private_ip             = "10.0.3.21"
  key_name               = aws_key_pair.helios_generated_key_pair.key_name
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
    ClusterName = var.CASSANDRA_CLUSTER_NAME
    DC          = "helios-dc"
    # Rack        = "rack1"
    Seeds       = "10.0.3.20,10.0.3.21"
    Environment = var.ENVIRONMENT
  }
  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}


resource "aws_instance" "cassandra_2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "i4i.2xlarge"
  availability_zone      = var.zone_1
  subnet_id              = aws_subnet.private-subnet-1.id
  vpc_security_group_ids = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id, aws_security_group.allow_private_subnet_all.id]
  private_ip             = "10.0.3.22"
  key_name               = aws_key_pair.helios_generated_key_pair.key_name
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
    Name        = "cassandra-2"
    Disposable  = "false"
    Scalable    = "false"
    Role        = "cassandra"
    Project     = "Helios Reference Architecture"
    ClusterName = var.CASSANDRA_CLUSTER_NAME
    DC          = "helios-dc"
    # Rack        = "rack1"
    Seeds       = "10.0.3.20,10.0.3.21"
    Environment = var.ENVIRONMENT
  }
  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}


resource "aws_instance" "cassandra_3" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "i4i.2xlarge"
  availability_zone      = var.zone_2
  subnet_id              = aws_subnet.private-subnet-2.id
  vpc_security_group_ids = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id, aws_security_group.allow_private_subnet_all.id]
  private_ip             = "10.0.4.23"
  key_name               = aws_key_pair.helios_generated_key_pair.key_name
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
    Name        = "cassandra-3"
    Disposable  = "false"
    Scalable    = "false"
    Role        = "cassandra"
    Project     = "Helios Reference Architecture"
    ClusterName = var.CASSANDRA_CLUSTER_NAME
    DC          = "helios-dc"
    # Rack        = "rack1"
    Seeds       = "10.0.3.20,10.0.3.21"
    Environment = var.ENVIRONMENT
  }
  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}


resource "aws_instance" "cassandra_4" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "i4i.2xlarge"
  availability_zone      = var.zone_2
  subnet_id              = aws_subnet.private-subnet-2.id
  vpc_security_group_ids = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id, aws_security_group.allow_private_subnet_all.id]
  private_ip             = "10.0.4.24"
  key_name               = aws_key_pair.helios_generated_key_pair.key_name
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
    Name        = "cassandra-4"
    Disposable  = "false"
    Scalable    = "false"
    Role        = "cassandra"
    Project     = "Helios Reference Architecture"
    ClusterName = var.CASSANDRA_CLUSTER_NAME
    DC          = "helios-dc"
    # Rack        = "rack1"
    Seeds       = "10.0.3.20,10.0.3.21"
    Environment = var.ENVIRONMENT
  }
  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}


