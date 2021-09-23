# ---------------------------------------------------
# Security Group for Internal Load Balancer
# ---------------------------------------------------
resource "aws_security_group" "internal-alb" {
  vpc_id = aws_vpc.primario.id
  name   = "3TA1"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Internal-LB"
  }
}
