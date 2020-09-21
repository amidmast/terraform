data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
  tags = {
    Name = "MyVPC-${var.project}"
  }
}
resource "aws_subnet" "public_1" {
  cidr_block        = "10.0.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id            = aws_vpc.main.id
  tags = {
    Name = "public_1-${var.project}"
  }
}
resource "aws_subnet" "public_2" {
  cidr_block        = "10.0.20.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  vpc_id            = aws_vpc.main.id
  tags = {
    Name = "public_2-${var.project}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "InetGW-${var.project}"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Route public-${var.project}"
  }
}
resource "aws_route_table_association" "public_1" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1.id
}
resource "aws_route_table_association" "public_2" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_2.id
}

#PRIVATE NETWORK
resource "aws_eip" "eip_1" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_eip" "eip_2" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_subnet" "private_1" {
  cidr_block        = "10.0.100.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id            = aws_vpc.main.id
  tags = {
    Name = "private_1-${var.project}"
  }
}
resource "aws_subnet" "private_2" {
  cidr_block        = "10.0.200.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  vpc_id            = aws_vpc.main.id
  tags = {
    Name = "private_2-${var.project}"
  }
}
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gateway_1.id
  }
  tags = {
    Name = "private_route_1-${var.project}"
  }
}
resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gateway_2.id
  }
  tags = {
    Name = "private_route_2-${var.project}"
  }
}

resource "aws_nat_gateway" "gateway_1" {
  allocation_id = aws_eip.eip_1.id
  subnet_id     = aws_subnet.public_1.id
}
resource "aws_nat_gateway" "gateway_2" {
  allocation_id = aws_eip.eip_2.id
  subnet_id     = aws_subnet.public_2.id
}

resource "aws_route_table_association" "private_1" {
  route_table_id = aws_route_table.private_1.id
  subnet_id      = aws_subnet.private_1.id
}
resource "aws_route_table_association" "private_2" {
  route_table_id = aws_route_table.private_2.id
  subnet_id      = aws_subnet.private_2.id
}
