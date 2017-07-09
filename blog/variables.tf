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
    "us-east-1" = "ami-a42d75b3"
  }
}

variable "zones" {
  type = "map"

  default = {
    "us-east-1" = "us-east-1b"
  }
}
