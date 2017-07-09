variable "name" {}

variable "aws_region" {}

variable "tags" {
  type = "map"
}

variable "env" {}

variable "az_count" {
  default = 1
}

variable "wordpress_images" {
  type = "map"

  default = {
    "us-east-1" = "ami-54d3f531"
  }
}

variable "zones" {
  type = "map"

  default = {
    "us-east-1" = "us-east-1b"
  }
}
