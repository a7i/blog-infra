output "wordpress_public_eip" {
  value = "${aws_eip.wordpress.public_ip}"
}

output "wordpress_public_dns" {
  value = "${aws_instance.wordpress.public_dns}"
}
