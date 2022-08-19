module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.1.0"
  cluster_name    = "${var.environment}-cluster"
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets
  tags = {
    Name = "${var.environment}-cluster"
  }
  vpc_id = module.vpc.vpc_id
#   workers_group_defaults = {
#     root_volume_type = "gp2"
#   }
#   worker_groups = [
#     {
#       name                          = "${var.environment}-Worker"
#       instance_type                 = "t2.micro"
#       asg_desired_capacity          = 1
#       additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
#       availability_zones            = ["ap-south-1a"]
#     },
#     {
#       name                          = "${var.environment}-Worker"
#       instance_type                 = "t2.micro"
#       asg_desired_capacity          = 1
#       additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
#       availability_zones            = ["ap-south-1b"]
#     },
#   ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}


resource "aws_eks_node_group" "eks_cluster" {
  cluster_name    = module.eks.cluster_id
  node_group_name = "${var.environment}-node"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = module.vpc.private_subnets
  instance_types   = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node-AmazonEC2ContainerRegistryReadOnly,
  ]
}


resource "aws_iam_role" "eks_node" {
  name = "${var.environment}-eks"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}
