terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "github_oidc" {
  source = "../../../modules/github-oidc"

  name_prefix                  = var.name_prefix
  repo                         = var.github_repo
  repo_subject                 = var.github_repo_subject
  create_oidc_provider         = var.create_oidc_provider
  ecr_repository_arn           = var.ecr_repository_arn
  infra_apply_managed_policies = var.infra_apply_managed_policies
  infra_plan_managed_policies  = var.infra_plan_managed_policies

  # The remote backend, so the CI roles can read the state. Must match
  # backend.tf. terraform plan compares against this; without it init fails
  # with a 403 on HeadObject.
  state_bucket_arn     = "arn:aws:s3:::myapp-tfstate-042617239394"
  state_lock_table_arn = "arn:aws:dynamodb:eu-central-1:042617239394:table/myapp-tflock"

  tags = var.tags
}

module "vpc" {
  source = "../../../modules/vpc"

  name_prefix  = var.name_prefix
  cluster_name = var.cluster_name
  tags         = var.tags
}

module "eks" {
  source = "../../../modules/eks"

  name_prefix            = var.name_prefix
  cluster_name           = var.cluster_name
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  endpoint_public_access = true
  tags                   = var.tags

  access_entries = {
    (module.github_oidc.infra_apply_role_arn) = {
      policies = ["arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"]
      username = "myapp-infra-apply"
    }
    (module.github_oidc.infra_plan_role_arn) = {
      policies = ["arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"]
      username = "myapp-infra-plan"
    }
  }
}

module "ecr" {
  source = "../../../modules/ecr"

  repository_name = var.name_prefix
  tags            = var.tags
}

module "secrets" {
  source = "../../../modules/secrets"

  name_prefix = "dev/${var.name_prefix}"
  tags        = var.tags
}

module "pod_identity_app" {
  source = "../../../modules/pod-identity"

  role_name            = "${var.name_prefix}-pod-app"
  cluster_name         = module.eks.cluster_name
  namespace            = "app"
  service_account_name = "app"
  create_association   = true
  managed_policy_arns  = []
  tags                 = var.tags
}

module "pod_identity_external_secrets" {
  source = "../../../modules/pod-identity"

  role_name            = "${var.name_prefix}-pod-external-secrets"
  cluster_name         = module.eks.cluster_name
  namespace            = "external-secrets"
  service_account_name = "external-secrets"
  create_association   = true
  managed_policy_arns  = []
  inline_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = [module.secrets.db_secret_arn, module.secrets.redis_secret_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = ["*"]
      }
    ]
  })
  tags = var.tags
}

# Platform controllers via Helm
module "argocd" {
  source = "../../../modules/helm-release"

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  chart_version    = var.argocd_chart_version
  namespace        = "argocd"
  create_namespace = true
  values           = []
  timeout          = 600
  wait             = true

  tags = var.tags
}

module "external_secrets" {
  source = "../../../modules/helm-release"

  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  chart_version    = var.external_secrets_chart_version
  namespace        = "external-secrets"
  create_namespace = true
  values           = []
  timeout          = 600
  wait             = true

  tags = var.tags
}

module "argocd_image_updater" {
  source = "../../../modules/helm-release"

  name             = "argocd-image-updater"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-image-updater"
  chart_version    = var.argocd_image_updater_chart_version
  namespace        = "argocd"
  create_namespace = false
  values           = []
  timeout          = 300
  wait             = true

  tags = var.tags
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = null
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }
}

module "ingress" {
  source = "../../../modules/ingress"

  namespace             = "ingress-nginx"
  nginx_ingress_version = "4.9.1"
  timeout               = 600
  tags                  = var.tags
}
