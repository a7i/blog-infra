resource "aws_security_group" "fargate_vpc_sg" {
  name   = "${var.name}-fargate"
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol  = "tcp"
    from_port = 0
    to_port   = 65535

    cidr_blocks = ["${var.cidr_blocks}"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.name}-fargate-sg"
    Environment = "${var.env}"
  }
}
