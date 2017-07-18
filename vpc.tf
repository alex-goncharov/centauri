resource "aws_vpc" "main" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = "${var.vpc_cidr_block}"

  tags = {
    Name              = "${var.cluster_name}"
    KubernetesCluster = "${var.cluster_name}"
    bunch             = "k8"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_network_acl" "main" {
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_eip" "nat_ip" {
  vpc = true
}

resource "aws_subnet" "main" {
  count             = "${length(var.cluster_ip_plan)}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${lookup(var.cluster_ip_plan[count.index], "subnet")}"
  availability_zone = "${lookup(var.cluster_ip_plan[count.index], "az")}"

  tags = {
    Name              = "${var.cluster_name}-private"
    KubernetesCluster = "${var.cluster_name}"
    bunch             = "k8"
  }
}

resource "aws_subnet" "gw" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.gw_subnet}"
  availability_zone = "eu-west-1a"

  tags = {
    Name              = "${var.cluster_name}-gw"
    KubernetesCluster = "${var.cluster_name}"
    bunch             = "k8"
  }
}

resource "aws_route_table" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    KubernetesCluster = "${var.cluster_name}"
    bunch             = "k8"
  }
}

resource "aws_route_table_association" "igw" {
  subnet_id      = "${aws_subnet.gw.id}"
  route_table_id = "${aws_route_table.igw.id}"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_ip.id}"
  subnet_id     = "${aws_subnet.gw.id}"
  depends_on    = ["aws_internet_gateway.igw"]
}

resource "aws_route_table" "nat" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    KubernetesCluster = "${var.cluster_name}"
    bunch             = "k8"
  }
}

resource "aws_route_table_association" "nat" {
  count          = "${length(var.cluster_ip_plan)}"
  subnet_id      = "${element(aws_subnet.main.*.id, count.index)}"
  route_table_id = "${aws_route_table.nat.id}"
}
