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
    desired_size = 2
    max_size     = 5
    min_size     = 2
  }
  update_config {
    max_unavailable = 1
  }
  labels = {
    role = "Helios-FHIR-Server"
    env = var.ENVIRONMENT
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.helios-eks-cluster
  ]
}
