data "aws_availability_zones" "available" {}

resource "aws_vpc" "VPC_TOLONI" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "VPC_TOLONI"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "toloni_private_subnet" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.VPC_TOLONI.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zones[count.index]

  tags = {
    Name = "SUBNET_TOLONI-${count.index}"
  }
}

# Gateway

resource "aws_internet_gateway" "toloni_intenet_gateway" {
  vpc_id = aws_vpc.VPC_TOLONI.id

  tags = {
    Name = "toloni_igw"
  }
}

resource "aws_route_table" "toloni_private_rt" {
  vpc_id = aws_vpc.VPC_TOLONI.id

  tags = {
    Name = "toloni_private"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.toloni_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.toloni_intenet_gateway.id
}

resource "aws_default_route_table" "toloni_private_rt" {
  default_route_table_id = aws_vpc.VPC_TOLONI.default_route_table_id

  tags = {
    Name = "toloni_private"
  }
}

