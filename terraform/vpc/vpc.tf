variable "aws_region" {}

# ✅ Add this block to declare the availability zones
data "aws_availability_zones" "zones" {}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.${count.index + 1}.0/24"

  # ✅ Use the availability zones declared above
  availability_zone = data.aws_availability_zones.zones.names[count.index]

  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnets" {
  value = aws_subnet.subnet[*].id
}
