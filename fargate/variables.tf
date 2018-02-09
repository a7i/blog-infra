variable "name" {}

variable "aws_region" {}

variable "tags" {
  type = "map"
}

variable "env" {}

variable "az_count" {
  default = 1
}

variable "zones" {
  type = "map"

  default = {
    "us-east-1" = "us-east-1b"
  }
}

variable "vpc_id" {}
variable "public_subnet_id" {}
variable "cidr_blocks" {}
