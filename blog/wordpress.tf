resource "tls_private_key" "wordpress" {
  algorithm = "RSA"
}

resource "aws_key_pair" "wordpress" {
  key_name   = "${var.name}-wordpress"
  public_key = "${tls_private_key.wordpress.public_key_openssh}"
}

resource "aws_security_group" "wordpress" {
  tags        = "${merge(var.tags, map("Name", "${var.name}-wordpress"))}"
  name        = "${var.name}-wordpress"
  vpc_id      = "${aws_vpc.blog.id}"
  description = "22 from all; all out"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "wordpress" {
  name = "${var.name}-wordpress"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "wordpress" {
  name = "wordpress"
  role = "${aws_iam_role.wordpress.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*",
        "logs:PutLogEvents",
        "logs:CreateLogGroup",
        "logs:CreateLogStream"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "wordpress" {
  name = "${var.name}-wordpress"
  role = "${aws_iam_role.wordpress.name}"

  provisioner "local-exec" {
    command = "sleep 90"
  }
}

data "aws_ami" "wordpress" {
  most_recent = true
  owners      = ["amazon"]

  filter = {
    name   = "name"
    values = ["amzn-ami-hvm-2017.03.*-x86_64-gp2"]
  }
}

resource "aws_instance" "wordpress" {
  count         = "1"
  tags          = "${merge(var.tags, map("Name", "${var.name}-wordpress${count.index}"))}"
  instance_type = "t2.micro"

  ami                    = "${lookup(var.wordpress_images, var.aws_region)}"
  vpc_security_group_ids = ["${aws_security_group.wordpress.id}"]
  subnet_id              = "${element(aws_subnet.public.*.id, count.index)}"
  key_name               = "${aws_key_pair.wordpress.key_name}"
  iam_instance_profile   = "${aws_iam_instance_profile.wordpress.id}"

  associate_public_ip_address = true
  source_dest_check           = false

  lifecycle {
    prevent_destroy = true
    ignore_changes  = ["ebs_block_device", "tags"]
  }

  ebs_block_device {
    device_name = "/dev/sdg"
    volume_size = 30
    volume_type = "st1"
    encrypted   = true
  }
}

resource "aws_eip" "wordpress" {
  instance = "${aws_instance.wordpress.id}"
  vpc      = true
}
