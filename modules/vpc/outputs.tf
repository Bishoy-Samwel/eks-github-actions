output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the VPC"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "CIDR block of the VPC"
}

output "availability_zones" {
  value       = local.azs
  description = "AZs used"
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "IDs of public subnets"
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private : s.id]
  description = "IDs of private subnets"
}

output "nat_gateway_ids" {
  value       = aws_nat_gateway.main[*].id
  description = "IDs of NAT gateways"
}

output "nat_gateway_public_ips" {
  value       = aws_eip.nat[*].public_ip
  description = "Public IPs of NAT gateways"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.main.id
  description = "ID of internet gateway"
}
