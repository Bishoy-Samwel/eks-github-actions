output "db_secret_arn" {
  value       = aws_secretsmanager_secret.db.arn
  description = "DB secret ARN"
}

output "redis_secret_arn" {
  value       = aws_secretsmanager_secret.redis.arn
  description = "Redis secret ARN"
}
