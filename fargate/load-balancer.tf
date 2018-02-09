resource "aws_security_group" "fargate_alb_sg" {
  name   = "${var.name}-fargate-alb-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "fargate_alb" {
  internal        = "false"
  subnets         = ["${split(",", var.public_subnet_id)}"]
  security_groups = ["${aws_security_group.fargate_alb_sg.id}"]
}

resource "aws_alb_target_group" "fargate_target_group" {
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"
}

resource "aws_alb_listener" "fargate_alb_listener" {
  load_balancer_arn = "${aws_alb.fargate_alb.id}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.fargate_target_group.id}"
    type             = "forward"
  }
}
