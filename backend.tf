terraform {
  backend "s3" {
    bucket  = "terraform-state"
    key     = "lovetraveldevour"
    region  = "us-east-1"
    encrypt = true
  }
}
