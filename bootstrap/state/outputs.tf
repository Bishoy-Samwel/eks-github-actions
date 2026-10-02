output "state_bucket_name" {
  value       = aws_s3_bucket.state.id
  description = "Name of the S3 bucket holding Terraform state"
}

output "state_bucket_arn" {
  value       = aws_s3_bucket.state.arn
  description = "ARN of the S3 bucket holding Terraform state"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.locks.name
  description = "Name of the DynamoDB table for state locking"
}

output "kms_key_arn" {
  value       = aws_kms_key.state.arn
  description = "ARN of the KMS key used to encrypt state"
}
