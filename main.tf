provider "aws" {
  region = "${var.aws_region}"
}

module "terraform-state" {
  source = "terraform-state"
  env    = "${var.env}"
  tags   = "${merge(var.tags, map("env", var.env, "maintainer", var.maintainer))}"
}

module "blog" {
  source     = "blog"
  name       = "blog-${var.env}"
  env        = "${var.env}"
  tags       = "${merge(var.tags, map("env", var.env, "maintainer", var.maintainer))}"
  aws_region = "${var.aws_region}"
}

module "fargate" {
  source           = "fargate"
  name             = "fargate-${var.env}"
  env              = "${var.env}"
  tags             = "${merge(var.tags, map("env", var.env, "Maintainer", var.maintainer))}"
  aws_region       = "${var.aws_region}"
  vpc_id           = "${module.blog.vpc_id}"
  public_subnet_id = "${module.blog.public_subnet_id}"
  cidr_blocks      = "${module.blog.cidr_blocks}"
}
