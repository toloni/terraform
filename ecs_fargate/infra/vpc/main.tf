# infra/vpc/main.tf

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-${var.app_name}"
  }
}

# PUBLIC SUBNET
resource "aws_subnet" "public-subnet" {
  count             = length(var.public_vpc_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_vpc_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

# PRIVATE SUBNET
resource "aws_subnet" "private-subnet" {
  count             = length(var.private_vpc_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_vpc_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "private-subnet-${count.index}"
  }
}

# PUBLIC ROUTE TABLE
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Public-Route-Table"
  }
}

# PRIVATE ROUTE TABLE
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Private-Route-Table"
  }
}

# TABLE ASSOCIATION
resource "aws_route_table_association" "public-subnet-association" {
  count          = length(var.public_vpc_cidrs)
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet[count.index].id
}

resource "aws_route_table_association" "private-subnet-association" {
  count          = length(var.private_vpc_cidrs)
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet[count.index].id
}

# ELASTIC IP
resource "aws_eip" "elastic-ip-for-nat-gtw" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"

  tags = {
    Name = "EIP-${var.app_name}"
  }
}

# NAT GATEWAY
resource "aws_nat_gateway" "nat-gw" {
  count         = 1
  allocation_id = aws_eip.elastic-ip-for-nat-gtw.id
  subnet_id     = aws_subnet.public-subnet[0].id

  tags = {
    Name = "NAT-GW-${var.app_name}"
  }

  depends_on = [aws_eip.elastic-ip-for-nat-gtw]
}

resource "aws_route" "nat-gw-route" {
  route_table_id         = aws_route_table.private-route-table.id
  nat_gateway_id         = aws_nat_gateway.nat-gw[0].id
  destination_cidr_block = "0.0.0.0/0"
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW-${var.app_name}"
  }
}

resource "aws_route" "public-internet-gw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}