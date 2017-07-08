resource "random_id" "db_password" {
  prefix      = "a"
  byte_length = 32
}

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
  description = "22 from bastion; all out"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
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
  instance_type = "${var.production ? "t2.small" : "t2.small"}"

  ami                    = "${data.aws_ami.wordpress.id}"
  vpc_security_group_ids = ["${aws_security_group.wordpress.id}"]
  subnet_id              = "${element(aws_subnet.backend.*.id, count.index)}"
  key_name               = "${aws_key_pair.wordpress.key_name}"
  iam_instance_profile   = "${aws_iam_instance_profile.wordpress.id}"

  associate_public_ip_address = false
  source_dest_check           = false

  depends_on = ["null_resource.deploy_bastion"]

  lifecycle {
    ignore_changes = ["ami"]
  }

  root_block_device {
    volume_size = "30"
  }

  user_data = <<EOF
#!/bin/bash
sudo yum update -y
cd /home/ec2-user
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
EOF
}
