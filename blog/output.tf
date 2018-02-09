output "wordpress_public_eip" {
  value = "${aws_eip.wordpress.public_ip}"
}

output "wordpress_public_dns" {
  value = "${aws_instance.wordpress.public_dns}"
}

output "vpc_id" {
  value = "${aws_vpc.blog.id}"
}

output "public_subnet_id" {
  value = "${aws_subnet.public.id}"
}

output "cidr_blocks" {
  value = "${aws_vpc.blog.cidr_block}"
}
