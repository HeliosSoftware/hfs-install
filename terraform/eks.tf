resource "aws_eks_cluster" "helios-eks-cluster" {
  name     = "helios-eks-cluster"
  role_arn = aws_iam_role.eksClusterRole.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.private-subnet-1.id,
      aws_subnet.private-subnet-2.id,
      aws_subnet.public-subnet-1.id,
      aws_subnet.public-subnet-2.id
    ]
  }
  tags = {
    Name        = "helios-eks-cluster"
    Environment = var.ENVIRONMENT
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.helios-eks-cluster.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.helios-eks-cluster.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.helios-eks-cluster.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "ebs-csi-driver" {
  cluster_name = aws_eks_cluster.helios-eks-cluster.name
  addon_name   = "aws-ebs-csi-driver"
}