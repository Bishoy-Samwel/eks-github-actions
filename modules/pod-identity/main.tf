terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAM role for pod identity
resource "aws_iam_role" "pod" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.pod_assume.json

  tags = var.tags
}

data "aws_iam_policy_document" "pod_assume" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

# Attach managed policies if provided
resource "aws_iam_role_policy_attachment" "pod" {
  count      = length(var.managed_policy_arns)
  role       = aws_iam_role.pod.name
  policy_arn = var.managed_policy_arns[count.index]
}

# Attach inline policy if provided
resource "aws_iam_role_policy" "pod_inline" {
  count  = var.inline_policy_json != null ? 1 : 0
  name   = "${var.role_name}-inline"
  role   = aws_iam_role.pod.id
  policy = var.inline_policy_json
}

# Pod Identity association
resource "aws_eks_pod_identity_association" "pod" {
  count = var.create_association ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account_name
  role_arn        = aws_iam_role.pod.arn

  tags = var.tags
}
