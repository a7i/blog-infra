variable "name" {}

variable "aws_region" {}

variable "tags" {
  type = "map"
}

variable "pipeline_role_arn" {}

variable "az_count" {
  default = 1
}

variable "env" {}