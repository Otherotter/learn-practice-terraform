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

resource "aws_security_group" "private_bastion_ssh" {
  vpc_id = aws_vpc.playground.id
  name   = "bastion-ssh"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_blocks.public_subnet_a1]
  }
  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = -1
      cidr_blocks      = [var.cidr_blocks.anywhere]
      description      = null
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }

  ]

  tags = {
    Name = "playground.private-bastion"
  }
}

locals {
  ubuntu_install_ansible = "./scripts/awsuserdata/ubuntu-install-ansible.sh"
}

resource "aws_instance" "playground-private-bastion" {
  ami                         = data.aws_ami.ubuntu_image.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.playground-private-b1.id
  associate_public_ip_address = false
  key_name                    = aws_key_pair.localkey.key_name
  vpc_security_group_ids      = [aws_security_group.private_bastion_ssh.id]
  user_data                   = fileexists(local.ubuntu_install_ansible) ? file(local.ubuntu_install_ansible) : null
  tags = {
    Name = "playground.private-bastion"
  }
}

resource "aws_security_group" "subservent" {
  vpc_id = aws_vpc.playground.id
  name   = "allow-private-bastion"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_blocks.private_subnet_b1]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_blocks.private_subnet_b1]
  }
  tags = {
    Name = "playground.subservents"
  }
}

resource "aws_key_pair" "private_bastion" {
  key_name   = "private-bastion"
  public_key = file("./keys/private-bastion.pub")
}

resource "aws_instance" "playground-subservents" {
  count                       = var.number_of_subservents
  ami                         = data.aws_ami.ubuntu_image.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.playground-private-b2.id
  associate_public_ip_address = false
  key_name                    = aws_key_pair.private_bastion.key_name
  vpc_security_group_ids      = [aws_security_group.subservent.id]

  tags = {
    Name = "playground.subservent${count.index}"
  }
}
