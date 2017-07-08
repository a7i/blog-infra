output "bastion_ips" {
  value = "${module.blog.bastion_ips}"
}

output "env" {
  value = "${var.env}"
}
