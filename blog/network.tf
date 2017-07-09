resource "aws_vpc" "blog" {
  tags                 = "${merge(var.tags, map("Name", var.name))}"
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  lifecycle {
    ignore_changes = ["tags"]
  }
}

resource "aws_internet_gateway" "blog" {
  tags   = "${merge(var.tags, map("Name", var.name))}"
  vpc_id = "${aws_vpc.blog.id}"

  lifecycle {
    ignore_changes = ["tags"]
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count                   = "${var.az_count}"
  tags                    = "${merge(var.tags, map("Name", "${var.name}-public${count.index}"))}"
  vpc_id                  = "${aws_vpc.blog.id}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block              = "10.0.1${count.index}1.0/24"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.blog"]

  lifecycle {
    ignore_changes = ["tags", "availability_zone"]
  }
}

resource "aws_route_table" "public" {
  tags   = "${merge(var.tags, map("Name", "${var.name}-public"))}"
  vpc_id = "${aws_vpc.blog.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.blog.id}"
  }

  lifecycle {
    ignore_changes = ["tags"]
  }
}

resource "aws_route_table_association" "public" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "blog" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, 0)}"
  depends_on    = ["aws_internet_gateway.blog"]
}

resource "aws_subnet" "db" {
  count             = "${var.az_count}"
  tags              = "${merge(var.tags, map("Name", "${var.name}-db${count.index}"))}"
  vpc_id            = "${aws_vpc.blog.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.1${count.index}4.0/24"

  lifecycle {
    ignore_changes = ["tags", "availability_zone"]
  }
}

resource "aws_route_table" "nat" {
  tags   = "${merge(var.tags, map("Name", "${var.name}-nat"))}"
  vpc_id = "${aws_vpc.blog.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.blog.id}"
  }

  lifecycle {
    ignore_changes = ["tags"]
  }
}
