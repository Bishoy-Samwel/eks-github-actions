terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_password" "db" {
  length  = var.password_length
  special = var.password_special
}

resource "random_password" "redis" {
  length  = var.password_length
  special = var.password_special
}

resource "aws_secretsmanager_secret" "db" {
  name        = "${var.name_prefix}/db"
  description = "Database password"
  kms_key_id  = var.kms_key_id

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({ password = random_password.db.result })
}

resource "aws_secretsmanager_secret" "redis" {
  name        = "${var.name_prefix}/redis"
  description = "Redis password"
  kms_key_id  = var.kms_key_id

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "redis" {
  secret_id     = aws_secretsmanager_secret.redis.id
  secret_string = jsonencode({ password = random_password.redis.result })
}
