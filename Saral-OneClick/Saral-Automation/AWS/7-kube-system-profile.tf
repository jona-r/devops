resource "aws_iam_role" "eks-fargate-profile" {
  name = "eks-fargate-profile"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-fargate-profile" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks-fargate-profile.name
}


resource "aws_eks_fargate_profile" "kube-system" {
  fargate_profile_name   = "kube-system"
  cluster_name           = aws_eks_cluster.cluster.name
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile.arn


  subnet_ids = [
    aws_subnet.private-ap-south-1a.id,
    aws_subnet.private-ap-south-1b.id,
  ]

  selector {
    namespace = "kube-system"
  }
}

resource "aws_eks_addon" "coredns" {
  cluster_name    = aws_eks_cluster.cluster.name
  addon_name      = "coredns"
  addon_version   = "v1.11.1-eksbuild.4"
}


