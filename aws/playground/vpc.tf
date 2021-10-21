# -----------------------------------
# VPC and Gateway Network Setup
# -----------------------------------
resource "aws_vpc" "playground" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "playground"
  }
}
resource "aws_internet_gateway" "playground" {
  vpc_id = aws_vpc.playground.id
  tags = {
    Name = "playground"
  }
}

# -----------------------------------
# Availability Zone: us-east-1a
# -----------------------------------

resource "aws_subnet" "playground-public-a" {
  vpc_id            = aws_vpc.playground.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "playground.public-alpha"
  }
}

resource "aws_subnet" "playground-private-b1" {
  vpc_id            = aws_vpc.playground.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "playground.privateb-alpha"
  }
}

resource "aws_subnet" "playground-private-b2" {
  vpc_id            = aws_vpc.playground.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "playground.publicb-beta"
  }
}
# -----------------------------------
# Route Table: Public
# -----------------------------------
resource "aws_route_table" "playground" {
  vpc_id = aws_vpc.playground.id
  tags = {
    Name = "playground.public-table"
  }
}

resource "aws_route_table_association" "playground" {
  subnet_id      = aws_subnet.playground-public-a.id
  route_table_id = aws_route_table.playground.id
}

resource "aws_route" "playground" {
  route_table_id         = aws_route_table.playground.id
  gateway_id             = aws_internet_gateway.playground.id
  destination_cidr_block = "0.0.0.0/0"
}
