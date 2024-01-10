//resource "aws_instance" "kubectl-server" {
//  ami                         = data.aws_ami.ubuntu.id
//  instance_type               = "t3.micro"
//  subnet_id                   = aws_subnet.public-subnet-1.id
//  vpc_security_group_ids      = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id, aws_security_group.allow_public_subnet_all.id]
//  key_name                    = aws_key_pair.helios_generated_key_pair.key_name
//  tags = {
//    Name = "kubectl-server"
//    Environment = var.ENVIRONMENT
//  }
//}

resource "aws_eks_node_group" "worker-nodes" {
  cluster_name    = aws_eks_cluster.helios-eks-cluster.name
  node_group_name = "worker-nodes"
  node_role_arn   = aws_iam_role.eksWorkerRole.arn
  subnet_ids = [
    aws_subnet.public-subnet-1.id,
    aws_subnet.public-subnet-2.id
  ]
  capacity_type  = "ON_DEMAND"
  instance_types = [var.worker_instance_type]
  disk_size      = "60"
  remote_access {
    ec2_ssh_key = aws_key_pair.helios_generated_key_pair.key_name
    source_security_group_ids = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id]
  }
  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }
  update_config {
    max_unavailable = 1
  }
  labels = {
    role = "Helios-FHIR-Server"
    env = var.ENVIRONMENT
  }


  # taint {
  #   key    = "team"
  #   value  = "devops"
  #   effect = "NO_SCHEDULE"
  # }

  # launch_template {
  #   name    = aws_launch_template.eks-worker_node_launch_template.name
  #   version = aws_launch_template.eks-worker_node_launch_template.latest_version
  # }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

# resource "aws_launch_template" "eks-worker_node_launch_template" {
#   name = "eks-worker_node_launch_template"
#   instance_type = "t3.xlarge"
#   block_device_mappings {
#     ebs {
#       volume_size = 60
#       volume_type = "gp3"
#     }
#   }
# }

# resource "aws_launch_template" "eks-with-disks" {
#   name = "eks-with-disks"

#   key_name = "local-provisioner"

#   block_device_mappings {
#     device_name = "/dev/xvdb"

#     ebs {
#       volume_size = 50
#       volume_type = "gp2"
#     }
#   }
# }