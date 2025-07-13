variable "aws_region" {}

data "aws_availability_zones" "zones" {}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "medusa-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.zones.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "medusa-subnet-${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "medusa-igw"
  }
}

# Route Table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "medusa-public-rt"
  }
}

# Associate route table with each subnet
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

# Outputs
output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnets" {
  value = aws_subnet.subnet[*].id
}
