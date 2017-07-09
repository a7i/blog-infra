provider "aws" {
  region = "${var.aws_region}"
}

module "terraform-state" {
  source = "terraform-state"
  tags   = "${merge(var.tags, map("env", var.env, "maintainer", var.maintainer))}"
}

module "blog" {
  source     = "blog"
  name       = "blog-${var.env}"
  tags       = "${merge(var.tags, map("env", var.env, "maintainer", var.maintainer))}"
  aws_region = "${var.aws_region}"
}
