# -----------------------------------
# VPC and Gateway Network Setup
# -----------------------------------
resource "aws_vpc" "primario" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "3TA.VPC"
  }
}
resource "aws_internet_gateway" "primario-gw" {
  vpc_id = aws_vpc.primario.id
  tags = {
    Name = "3TA.IGW"
  }
}

# -----------------------------------
# Availability Zone: us-east-1a 
# -----------------------------------

resource "aws_subnet" "publico_uno" {
  vpc_id            = aws_vpc.primario.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zone_one
  tags = {
    Name = "Three-Teir-App.use1a.Publico-Uno"
  }
}
resource "aws_subnet" "privado_uno" {
  vpc_id            = aws_vpc.primario.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zone_one
  tags = {
    Name = "Three-Teir-App.use1a.Privado-Uno"
  }
}

# -----------------------------------
# Availability Zone: us-east-1b 
# -----------------------------------

resource "aws_subnet" "publico_dos" {
  vpc_id            = aws_vpc.primario.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.availability_zone_two
  tags = {
    Name = "Three-Teir-App.use1a.Publico-Dos"
  }
}
resource "aws_subnet" "privado_dos" {
  vpc_id            = aws_vpc.primario.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.availability_zone_two
  tags = {
    Name = "Three-Teir-App.use1a.Privado-Dos"
  }
}

# -----------------------------------
# Route Table: Public
# -----------------------------------
resource "aws_route_table" "tabla_ruta_publico" {
  vpc_id = aws_vpc.primario.id
  tags = {
    Name = "3TA.Public-Route"
  }
}
resource "aws_route_table_association" "asociacion-publico-uno" {
  subnet_id      = aws_subnet.publico_uno.id
  route_table_id = aws_route_table.tabla_ruta_publico.id
}
resource "aws_route_table_association" "asociacion-publico-dos" {
  subnet_id      = aws_subnet.publico_dos.id
  route_table_id = aws_route_table.tabla_ruta_publico.id
}
resource "aws_route" "ruta_publico_uno" {
  route_table_id         = aws_route_table.tabla_ruta_publico.id
  gateway_id             = aws_internet_gateway.primario-gw.id
  destination_cidr_block = "0.0.0.0/0"
}

# -----------------------------------
# Route Table: Private
# -----------------------------------
resource "aws_route_table" "tabla_ruta_privado" {
  vpc_id = aws_vpc.primario.id
  tags = {
    Name = "3TA.Private-Route"
  }
}

resource "aws_route_table_association" "asociacion-privado-uno" {
  subnet_id      = aws_subnet.privado_uno.id
  route_table_id = aws_route_table.tabla_ruta_privado.id
}

resource "aws_route_table_association" "asociacion-privado-dos" {
  subnet_id      = aws_subnet.privado_dos.id
  route_table_id = aws_route_table.tabla_ruta_privado.id
}

resource "aws_route" "ruta_privado_uno" {
  route_table_id         = aws_route_table.tabla_ruta_privado.id
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
  destination_cidr_block = "0.0.0.0/0"
}

# --------------------------------------------------------------------------
# NAT Gateway us-east-1b: resources = {EIP, NGW}
# --------------------------------------------------------------------------
resource "aws_eip" "nat-gw-ip" {
  vpc = true
  tags = {
    Name = "3TA.NATGW-IP"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-gw-ip.id
  subnet_id     = aws_subnet.publico_dos.id
  tags = {
    Name = "3TA.nat-gw"
  }
}

# --------------------------------------------------------------------------
# SSH-Only Machine in us-east-1a: resources = {SG, AMI, KEYPAIR, INSTANCE}
# --------------------------------------------------------------------------

resource "aws_security_group" "ssh-only" {
  vpc_id = aws_vpc.primario.id
  name   = "3TA2"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SSH-Only"
  }
}

data "aws_ami" "ubuntu_image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "localkey" {
  key_name   = "local-machine-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu_image.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.publico_uno.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.localkey.key_name
  vpc_security_group_ids      = [aws_security_group.ssh-only.id]
  user_date = fileexists("bastionhost.sh") : file("bastionhost.sh") ? null
  tags = {
    Name = "3TA.Bastion-Host"
  }
}
