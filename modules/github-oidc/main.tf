terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  repo_subject      = var.repo_subject != "" ? var.repo_subject : var.repo
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
}

data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 0 : 1
  url   = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.github_oidc_thumbprints
}

data "aws_iam_policy_document" "break_glass_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = length(var.break_glass_principals) > 0 ? var.break_glass_principals : ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "ci_ecr_push" {
  name               = "${var.name_prefix}-ci-ecr-push"
  assume_role_policy = data.aws_iam_policy_document.ci_ecr_push_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "ci_ecr_push_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:${local.repo_subject}:ref:refs/heads/main",
        "repo:${local.repo_subject}:environment:production"
      ]
    }
  }
}

resource "aws_iam_role_policy" "ci_ecr_push" {
  name   = "${var.name_prefix}-ci-ecr-push"
  role   = aws_iam_role.ci_ecr_push.id
  policy = data.aws_iam_policy_document.ci_ecr_push_policy.json
}

data "aws_iam_policy_document" "ci_ecr_push_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.ecr_repository_arn == "" ? [] : [1]
    content {
      effect = "Allow"
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:BatchGetImage",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages"
      ]
      resources = [var.ecr_repository_arn]
    }
  }
}

resource "aws_iam_role" "infra_plan" {
  name               = "${var.name_prefix}-infra-plan"
  assume_role_policy = data.aws_iam_policy_document.infra_plan_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "infra_plan_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.repo_subject}:pull_request"]
    }
  }
}

resource "aws_iam_role_policy" "infra_plan" {
  name   = "${var.name_prefix}-infra-plan"
  role   = aws_iam_role.infra_plan.id
  policy = data.aws_iam_policy_document.infra_plan_policy.json
}

data "aws_iam_policy_document" "infra_plan_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.ecr_repository_arn == "" ? [] : [1]
    content {
      effect = "Allow"
      actions = [
        "ecr:DescribeRepositories"
      ]
      resources = [var.ecr_repository_arn]
    }
  }
}

resource "aws_iam_role" "infra_apply" {
  name               = "${var.name_prefix}-infra-apply"
  assume_role_policy = data.aws_iam_policy_document.infra_apply_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "infra_apply_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.repo_subject}:environment:production"]
    }
  }
}

resource "aws_iam_role_policy" "infra_apply_iam" {
  name   = "${var.name_prefix}-infra-apply-iam"
  role   = aws_iam_role.infra_apply.id
  policy = data.aws_iam_policy_document.infra_apply_iam_policy.json
}

data "aws_iam_policy_document" "infra_apply_iam_policy" {
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:UpdateRole",
      "iam:PassRole"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "infra_apply" {
  count      = length(var.infra_apply_managed_policies)
  role       = aws_iam_role.infra_apply.name
  policy_arn = var.infra_apply_managed_policies[count.index]
}

resource "aws_iam_role" "break_glass" {
  name               = "${var.name_prefix}-break-glass"
  assume_role_policy = data.aws_iam_policy_document.break_glass_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "break_glass" {
  role       = aws_iam_role.break_glass.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
