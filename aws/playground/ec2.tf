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

# --------------------------------------------------------------------------
# SSH-Only Public Bastion in us-east-1a: resources = {SG, AMI, KEYPAIR, INSTANCE}
# --------------------------------------------------------------------------
resource "aws_security_group" "ssh-only" {
  vpc_id = aws_vpc.playground.id
  name   = "playground"
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

resource "aws_key_pair" "localkey" {
  key_name   = "local-machine-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "playground-bastion" {
  ami                         = data.aws_ami.ubuntu_image.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.playground-public-a.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.localkey.key_name
  vpc_security_group_ids      = [aws_security_group.ssh-only.id]
  tags = {
    Name = "playground.bastion"
  }
}

# --------------------------------------------------------------------------
# Private Bastion in us-east-1b: resources = {SG, AMI, KEYPAIR, INSTANCE}
# --------------------------------------------------------------------------
resource "aws_key_pair" "private_bastion" {
  key_name   = "private"
  public_key = file("./keys/private-bastion.pub")
}

resource "aws_security_group" "bastion_ssh" {
  vpc_id = aws_vpc.playground.id
  name   = "bastion-ssh"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  tags = {
    Name = "SSH-Only"
  }
}

resource "aws_instance" "playground-private-bastion" {
  ami                         = data.aws_ami.ubuntu_image.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.playground-private-b1.id
  associate_public_ip_address = false
  key_name                    = aws_key_pair.localkey.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_ssh.id]
  tags = {
    Name = "playground.private-bastion"
  }
}

resource "aws_security_group" "private" {
  vpc_id = aws_vpc.playground.id
  name   = "private"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.2.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.2.0/24"]
  }
  tags = {
    Name = "SSH-Only"
  }
}
resource "aws_instance" "playground-subservents" {
  count                       = var.number_of_subservents
  ami                         = data.aws_ami.ubuntu_image.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.playground-private-b2.id
  associate_public_ip_address = false
  key_name                    = aws_key_pair.private_bastion.key_name
  vpc_security_group_ids      = [aws_security_group.private.id]
  tags = {
    Name = "playground.subservent${count.index}"
  }
}
