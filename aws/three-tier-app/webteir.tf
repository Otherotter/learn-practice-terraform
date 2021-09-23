### Web-Teir ###

# ------------------------------------------------------------
# Auto-Scaling-Group: resouces = {AMI, LC, ASG}
# ------------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "web_conf" {
  name_prefix   = "3TA.Web"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.localkey.key_name
  user_data = fileexists("./scripts/userdata.sh") ? file("./scripts/userdata.sh") : null
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "3TA-Web-Frontend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.primario.id
}


resource "aws_autoscaling_group" "webservers" {
  name                      = "3TA.Webscalng"
  launch_configuration      = aws_launch_configuration.web_conf.name
  min_size                  = 2
  max_size                  = 5
  health_check_grace_period = 1000
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.publico_uno.id, aws_subnet.publico_dos.id]
  target_group_arns         = [aws_lb_target_group.web_tg.id]
  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------
# Internet Facing Load Balancer: resouces = {SG, ALB}
# ------------------------------------------------------------
variable "internet-facing-rules" {
  type = list(object({
    port        = number
    proto       = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      port        = 80
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 443
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port = 22
      proto = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  ]
}
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.primario.id
  name   = "3TA-Internet-Facing-Balancer"
  dynamic "ingress" {
    for_each = var.internet-facing-rules
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "3TA-Internet-Facing-Balancer"
  }
}

resource "aws_lb" "frontend_lb" {
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.publico_uno.id, aws_subnet.publico_dos.id]
  security_groups    = [aws_security_group.web_sg.id]
}

resource "aws_lb_listener" "frontend_http_listener" {
  load_balancer_arn = aws_lb.frontend_lb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.id
  }
}
