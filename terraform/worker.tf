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
  disk_size      = "120"
  remote_access {
    ec2_ssh_key               = aws_key_pair.helios_generated_key_pair.key_name
    source_security_group_ids = [aws_security_group.allow_outbound_all.id, aws_security_group.allow_tls.id]
  }
  scaling_config {
    desired_size = 4 
    max_size     = 5
    min_size     = 2
  }
  update_config {
    max_unavailable = 1
  }
  labels = {
    role = "Helios-FHIR-Server"
    env  = var.ENVIRONMENT
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.helios-eks-cluster
  ]
  // This doesn't work - and likely won't in the future:  https://github.com/hashicorp/terraform-provider-aws/issues/16825
  tags = {
    Name = "Helios FHIR Server"
  }
  timeouts {
    delete = "30m"
  }
}
resource "aws_autoscaling_policy" "helios-scaling" {
  name                      = "cpu-utilization-scaling-policy"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 300
  autoscaling_group_name    = aws_eks_node_group.worker-nodes.resources[0].autoscaling_groups[0].name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}
resource "aws_iam_policy" "cw_metrics_policy" {
  name        = "CWMetricsPolicy"
  description = "Policy to allow CloudWatch to collect metrics for autoscaling."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "cw_metrics_policy_attachment" {
  role       = aws_iam_role.eksWorkerRole.name
  policy_arn = aws_iam_policy.cw_metrics_policy.arn
}
