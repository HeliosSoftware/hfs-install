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
  depends_on                  = [aws_instance.cassandra_0, aws_instance.cassandra_1, aws_instance.cassandra_2]
  source_dest_check = false
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-get update",
      "sudo apt-get -y install python3-pip",
      "sudo apt-get -y install pipenv",
      "sudo apt-add-repository -y ppa:ansible/ansible",
      "sudo apt --yes update",
      "sudo apt --yes install ansible",
      "sudo pip3 install boto3",
      "sudo pip3 install ansible",
      "sudo apt --yes install unzip",
      "curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.28.3/2023-11-14/bin/linux/amd64/kubectl",
      "chmod +x ./kubectl",
      "mkdir -p /home/ubuntu/bin && cp ./kubectl /home/ubuntu/bin/kubectl && chown ubuntu:ubuntu /home/ubuntu/bin && chown ubuntu:ubuntu /home/ubuntu/bin/kubectl",
      "echo 'export PATH=/home/ubuntu/bin:$PATH' >> /home/ubuntu/.bashrc",
      "echo 'source /home/ubuntu/hfs-install/.aws/config' >> /home/ubuntu/.bashrc",
      "echo 'aws eks update-kubeconfig --region ${var.AWS_DEFAULT_REGION} --name ${aws_eks_cluster.helios-eks-cluster.name}' >> /home/ubuntu/.bashrc",
      "git clone https://github.com/HeliosSoftware/hfs-install.git /home/ubuntu/hfs-install",
      "mkdir /home/ubuntu/hfs-install/.aws",
      "chown -R ubuntu:ubuntu /home/ubuntu/hfs-install",
      "echo '${tls_private_key.ssh.private_key_openssh}' >> /home/ubuntu/.ssh/id_ed25519",
      "echo '${tls_private_key.ssh.public_key_openssh}' >> /home/ubuntu/.ssh/id_ed25519.pub",
      "chown ubuntu:ubuntu /home/ubuntu/.ssh/id_ed25519",
      "chown ubuntu:ubuntu /home/ubuntu/.ssh/id_ed25519.pub",
      "chmod 400 /home/ubuntu/.ssh/id_ed25519"
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = file(var.local_ssh_private_key)
    }
  }
  provisioner "file" {
    source      = "../.aws/config"
    destination = "/home/ubuntu/hfs-install/.aws/config"
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = file(var.local_ssh_private_key)
    }
  }
  provisioner "remote-exec" {
    inline = [
      "bash -c 'aws elb modify-load-balancer-attributes --load-balancer-name ${data.aws_elb.aws-hfs-lb.name} --load-balancer-attributes \"{\\\"ConnectionSettings\\\":{\\\"IdleTimeout\\\":1200}}\"'",
      "cd hfs-install",
      "cd ansible",
      "bash apache-cassandra-axonops.sh",
      "bash start-cassandra.sh"
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = file(var.local_ssh_private_key)
    }
  }
}

resource "aws_instance" "cassandra_0" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "i4i.2xlarge"
  availability_zone      = var.zone_1
  subnet_id              = aws_subnet.private-subnet-1.id
  vpc_security_group_ids = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id, aws_security_group.allow_private_subnet_all.id, aws_security_group.allow_cassandra.id]
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
    Region      = var.AWS_DEFAULT_REGION
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
  vpc_security_group_ids = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id, aws_security_group.allow_private_subnet_all.id, aws_security_group.allow_cassandra.id]
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
    Region      = var.AWS_DEFAULT_REGION
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
  availability_zone      = var.zone_2
  subnet_id              = aws_subnet.private-subnet-2.id
  vpc_security_group_ids = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id, aws_security_group.allow_private_subnet_all.id, aws_security_group.allow_cassandra.id]
  private_ip             = "10.0.4.22"
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
    Region      = var.AWS_DEFAULT_REGION
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
//  IMPORTANT - Should you wish to add more than 3 Cassandra nodes and you're using AxonOps'
//              free trial account, you will need to contact AxonOps or Helios Software as
//              AxonOps' free trial account is limited to 3 Cassandra nodes initially.
//resource "aws_instance" "cassandra_3" {
//  ami           = data.aws_ami.ubuntu.id
//  instance_type = "i4i.2xlarge"
//  availability_zone      = var.zone_2
//  subnet_id              = aws_subnet.private-subnet-2.id
//  vpc_security_group_ids = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id, aws_security_group.allow_private_subnet_all.id, aws_security_group.allow_cassandra.id]
//  private_ip             = "10.0.4.23"
//  key_name               = aws_key_pair.helios_generated_key_pair.key_name
//  ebs_optimized          = true
//  root_block_device {
//    delete_on_termination = true
//    encrypted = true
//    volume_size = 20
//    volume_type = "gp3"
//  }
//  ephemeral_block_device {
//    device_name = "/dev/sdc"
//    virtual_name = "ephemeral0"
//  }
//  metadata_options {
//    instance_metadata_tags = "enabled"
//    http_endpoint          = "enabled"
//  }
//  tags = {
//    Region      = var.AWS_DEFAULT_REGION
//    Name        = "cassandra-3"
//    Disposable  = "false"
//    Scalable    = "false"
//    Role        = "cassandra"
//    Project     = "Helios Reference Architecture"
//    ClusterName = var.CASSANDRA_CLUSTER_NAME
//    DC          = "helios-dc"
//    # Rack        = "rack1"
//    Seeds       = "10.0.3.20,10.0.3.21"
//    Environment = var.ENVIRONMENT
//  }
//  lifecycle {
//    ignore_changes = [
//      ami,
//      user_data
//    ]
//  }
//}
//
//resource "aws_instance" "cassandra_4" {
//  ami           = data.aws_ami.ubuntu.id
//  instance_type = "i4i.2xlarge"
//  availability_zone      = var.zone_2
//  subnet_id              = aws_subnet.private-subnet-2.id
//  vpc_security_group_ids = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id, aws_security_group.allow_private_subnet_all.id, aws_security_group.allow_cassandra.id]
//  private_ip             = "10.0.4.24"
//  key_name               = aws_key_pair.helios_generated_key_pair.key_name
//  ebs_optimized          = true
//  root_block_device {
//    delete_on_termination = true
//    encrypted = true
//    volume_size = 20
//    volume_type = "gp3"
//  }
//  ephemeral_block_device {
//    device_name = "/dev/sdc"
//    virtual_name = "ephemeral0"
//  }
//  metadata_options {
//    instance_metadata_tags = "enabled"
//    http_endpoint          = "enabled"
//  }
//  tags = {
//    Region      = var.AWS_DEFAULT_REGION
//    Name        = "cassandra-4"
//    Disposable  = "false"
//    Scalable    = "false"
//    Role        = "cassandra"
//    Project     = "Helios Reference Architecture"
//    ClusterName = var.CASSANDRA_CLUSTER_NAME
//    DC          = "helios-dc"
//    # Rack        = "rack1"
//    Seeds       = "10.0.3.20,10.0.3.21"
//    Environment = var.ENVIRONMENT
//  }
//  lifecycle {
//    ignore_changes = [
//      ami,
//      user_data
//    ]
//  }
//}

# Bastion Gateway Server
resource "aws_instance" "test_import_server1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  tags = {
    Name        = "Test Import Server 1"
    Role        = "gateway"
    Environment = var.ENVIRONMENT
  }
  availability_zone           = var.zone_1
  subnet_id                   = aws_subnet.public-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id]
  private_ip                  = "10.0.1.9"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.helios_local_key_pair.key_name
  ebs_optimized               = true
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
  depends_on                  = [aws_instance.cassandra_0, aws_instance.cassandra_1, aws_instance.cassandra_2]
  source_dest_check = false
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-get update",
      "echo '${tls_private_key.ssh.private_key_openssh}' >> /home/ubuntu/.ssh/id_ed25519",
      "echo '${tls_private_key.ssh.public_key_openssh}' >> /home/ubuntu/.ssh/id_ed25519.pub",
      "chown ubuntu:ubuntu /home/ubuntu/.ssh/id_ed25519",
      "chown ubuntu:ubuntu /home/ubuntu/.ssh/id_ed25519.pub",
      "chmod 400 /home/ubuntu/.ssh/id_ed25519",
      "wget -O - https://apt.corretto.aws/corretto.key | sudo gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg && echo 'deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main' | sudo tee /etc/apt/sources.list.d/corretto.list",
      "sudo apt-get update; sudo apt-get install -y java-11-amazon-corretto-jdk",
      "git clone https://github.com/synthetichealth/synthea.git",
      "git clone https://github.com/HeliosSoftware/fhir-importer.git",
      "cd fhir-importer",
      "sudo apt -y install maven",
      "mvn clean install",
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = file(var.local_ssh_private_key)
    }
  }
}