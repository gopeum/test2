## IAM - EKS Cluster Role
data "aws_iam_policy_document" "eks_cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.project_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

## IAM - Node Role
data "aws_iam_policy_document" "eks_node_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node_role" {
  name               = "${var.project_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume.json
}

resource "aws_iam_role_policy_attachment" "worker" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

## EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = "${var.project_name}-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_cluster_version

  vpc_config {
    subnet_ids              = var.eks_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
    security_group_ids      = [var.cluster_security_group_id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

## Node Group - Web
resource "aws_eks_node_group" "web" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-web"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.private_subnet_ids
  ami_type = "AL2023_x86_64_STANDARD"

  instance_types = [var.node_instance_type]

  scaling_config {
    desired_size = var.web_desired
    min_size     = var.web_min
    max_size     = var.web_max
  }

  labels = {
    role = "web"
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.ecr
  ]
}

## Node Group - WAS
resource "aws_eks_node_group" "was" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-was"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.private_subnet_ids
  ami_type = "AL2023_x86_64_STANDARD"

  instance_types = [var.node_instance_type]

  scaling_config {
    desired_size = var.was_desired
    min_size     = var.was_min
    max_size     = var.was_max
  }

  labels = {
    role = "was"
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.ecr
  ]
}

## aws-auth ConfigMap 적용 (null_resource)
resource "null_resource" "aws_auth_apply" {
  depends_on = [
    aws_eks_node_group.web,
    aws_eks_node_group.was
  ]

  provisioner "local-exec" {
    command = <<EOT
aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --region ap-northeast-2

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.node_role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOF
EOT
  }
}