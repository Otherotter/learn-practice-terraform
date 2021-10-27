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
  cidr_block        = var.cidr_blocks.public_subnet_a1
  availability_zone = var.avail_zone.zone_1
  tags = {
    Name = "playground.public-alpha"
  }
}

resource "aws_subnet" "playground-private-b1" {
  vpc_id            = aws_vpc.playground.id
  cidr_block        = var.cidr_blocks.private_subnet_b1
  availability_zone = var.avail_zone.zone_2
  tags = {
    Name = "playground.privateb-alpha"
  }
}

resource "aws_subnet" "playground-private-b2" {
  vpc_id            = aws_vpc.playground.id
  cidr_block        = var.cidr_blocks.private_subnet_b2
  availability_zone = var.avail_zone.zone_2
  tags = {
    Name = "playground.privateb-beta"
  }
}

# --------------------------------------------------------------------------
# NAT Gateway us-east-1b: resources = {EIP, NGW}
# --------------------------------------------------------------------------
resource "aws_eip" "nat-gw-ip" {
  vpc = true
  tags = {
    Name = "playground.b.ip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat-gw-ip.id
  subnet_id     = aws_subnet.playground-public-a.id
  tags = {
    Name = "playground.natgateway"
  }
}
# --------------------------------------------------------
# Route Table: Allows internet acesss in and out of zone A
# --------------------------------------------------------
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

# -----------------------------------
# Route Table: Private
# -----------------------------------
resource "aws_route_table" "privada" {
  vpc_id = aws_vpc.playground.id
  tags = {
    Name = "playground.private-route"
  }
}

resource "aws_route_table_association" "asociacion-privado-uno" {
  subnet_id      = aws_subnet.playground-private-b1.id
  route_table_id = aws_route_table.privada.id
}

resource "aws_route_table_association" "asociacion-privado-dos" {
  subnet_id      = aws_subnet.playground-private-b2.id
  route_table_id = aws_route_table.privada.id
}

resource "aws_route" "ruta_privado_uno" {
  route_table_id         = aws_route_table.privada.id
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
  destination_cidr_block = "0.0.0.0/0"
}
