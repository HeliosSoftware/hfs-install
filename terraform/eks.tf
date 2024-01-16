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

data "aws_eks_cluster_auth" "helios-eks-cluster" {
  name = "helios-eks-cluster"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.helios-eks-cluster.endpoint
  token                  = data.aws_eks_cluster_auth.helios-eks-cluster.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.helios-eks-cluster.certificate_authority.0.data)
}

resource "kubernetes_namespace" "helios-fhir-server" {
  metadata {
    name = "helios-fhir-server"
  }
}

resource "kubernetes_deployment" "helios-fhir-server" {
  metadata {
    name = "helios-fhir-server"
    namespace = kubernetes_namespace.helios-fhir-server.id
  }
  spec {
    replicas = 2
    selector {match_labels = {app = "helios-fhir-server"}}
    template {
      metadata {labels = {app =  "helios-fhir-server"}}
      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key = "kubernetes.io/arch"
                  operator = "In"
                  values = ["amd64"]
                }
              }
            }
          }
        }
        container {
          name = "helios-fhir-server"
          image = "gcr.io/helios-fhir-server/enterprise-edition:latest"
          port {
            container_port = 8181
          }
          image_pull_policy = "IfNotPresent"
          startup_probe {
            http_get {
              path = "/fhir/healthcheck"
              port = 8181
            }
            failure_threshold = 30
            period_seconds = 10
          }
          liveness_probe {
            http_get {
              path = "/fhir/healthcheck"
              port = 8181
            }
            failure_threshold = 1
            period_seconds = 10
          }
          env {
            name = "CASSANDRA_PROPERTIES_PORT"
            value = "9042"
          }
          env {
            name = "CASSANDRA_PROPERTIES_CONTACTPOINTS"
            value = "10.0.3.20,10.0.4.23"
          }
          env {
            name = "CASSANDRA_PROPERTIES_DATACENTER"
            value = "helios-dc"
          }
          env {
            name = "CASSANDRA_PROPERTIES_USERNAME"
            value = "cassandra"
          }
          env {
            name = "CASSANDRA_PROPERTIES_PASSWORD"
            value = "cassandra"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "helios-fhir-server" {
  metadata {
    name = "helios-fhir-server"
    namespace = kubernetes_namespace.helios-fhir-server.id
  }
  spec {
    type = "LoadBalancer"
    port {
      protocol = "TCP"
      port = 80
      target_port = 8181
    }
    selector = {
      app = "helios-fhir-server"
    }
  }
}
