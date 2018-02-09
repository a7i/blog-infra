resource "random_id" "db_password" {
  prefix      = "a"
  byte_length = 32
}

resource "aws_db_subnet_group" "blog" {
  name       = "${var.name}"
  tags       = "${merge(var.tags, map("Name", "${var.name}-master"))}"
  subnet_ids = ["${aws_subnet.db.*.id}"]

  lifecycle {
    ignore_changes = ["tags"]
  }
}

resource "aws_security_group" "db" {
  tags        = "${merge(var.tags, map("Name", "${var.name}-db"))}"
  name        = "${var.name}-db"
  vpc_id      = "${aws_vpc.blog.id}"
  description = "5432 from wordpress; all out"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${aws_security_group.wordpress.id}"]
  }

  lifecycle {
    ignore_changes = ["tags"]
  }
}

# resource "aws_db_instance" "master" {
#   identifier                 = "${var.name}-master"
#   tags                       = "${merge(var.tags, map("Name", "${var.name}-master"))}"
#   db_subnet_group_name       = "${aws_db_subnet_group.blog.id}"
#   availability_zone          = "${element(aws_subnet.db.*.availability_zone, 0)}"
#   vpc_security_group_ids     = ["${aws_security_group.db.id}"]
#   instance_class             = "db.t2.micro"
#   storage_encrypted          = true
#   auto_minor_version_upgrade = false
#   storage_type               = "gp2"
#   iops                       = "0"
#   copy_tags_to_snapshot      = "true"
#   backup_retention_period    = "7"
#
#   engine              = "mysql"
#   name                = "blog"
#   username            = "postgres"
#   password            = "${random_id.db_password.b64}"
#   allocated_storage   = "2"
#   skip_final_snapshot = "true"
#
#   lifecycle {
#     prevent_destroy = true
#     ignore_changes  = ["tags", "version"]
#   }
# }

