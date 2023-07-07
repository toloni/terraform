output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnets" {
  value = aws_subnet.public-subnet[*].id
}

output "private_subnets" {
  value = aws_subnet.private-subnet[*].id
}