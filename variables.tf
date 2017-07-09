variable "env" {
  description = "The environment name. Resources are tagged with this identifier. When testing locally, it should be set to the username."
}

variable "tags" {
  type        = "map"
  description = "Tags applied to all AWS resources"
  default     = {}
}

variable "aws_region" {
  default = "us-east-1"
}

variable "maintainer" {
  description = "maintainer of blog resources"
  default     = "amir.alavi@yahoo.com"
}