output "bastion_ips" {
  value = "${join(",", aws_eip.bastion.*.public_ip)}"
}