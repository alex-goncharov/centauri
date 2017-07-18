resource "aws_iam_role" "gw" {
  name               = "gw"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_trust.json}"
}

resource "aws_iam_instance_profile" "gw" {
  name = "gw"
  role = "${aws_iam_role.gw.name}"
}

resource "aws_security_group" "gw" {
  name        = "gw"
  description = "gw security group"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name  = "gw"
    bunch = "k8"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }
}

resource "aws_instance" "gw" {
  ami                         = "${var.default_ami}"
  instance_type               = "t2.micro"
  key_name                    = "${var.key_name}"
  monitoring                  = false
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.gw.name}"
  subnet_id                   = "${aws_subnet.gw.id}"
  ebs_optimized               = false

  vpc_security_group_ids = [
    "${aws_security_group.gw.id}",
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  tags {
    Name  = "k8gw"
    bunch = "k8"
  }

  lifecycle {
    create_before_destroy = true
  }
}
