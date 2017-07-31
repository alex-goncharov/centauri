resource "aws_iam_role" "master" {
  name               = "k8_master_node"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_trust.json}"
}

resource "aws_iam_instance_profile" "master" {
  name = "k8_master_node"
  role = "${aws_iam_role.master.name}"
}

resource "aws_autoscaling_group" "master" {
  tag {
    key                 = "Name"
    value               = "k8-master"
    propagate_at_launch = true
  }

  tag {
    key                 = "KubernetesCluster"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "role"
    value               = "k8master"
    propagate_at_launch = true
  }

  tag {
    key                 = "bunch"
    value               = "k8"
    propagate_at_launch = true
  }

  name                      = "k8-masters"
  vpc_zone_identifier       = ["${aws_subnet.main.*.id}"]
  max_size                  = "${var.master_count}"
  min_size                  = "${var.master_count}"
  health_check_grace_period = 900
  health_check_type         = "EC2"
  desired_capacity          = "${var.master_count}"
  launch_configuration      = "${aws_launch_configuration.master.name}"
}

resource "aws_security_group" "master_to_master" {
  name        = "master_to_master"
  description = "Allows traffic between masters"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name              = "master_to_master"
    KubernetesCluster = "${var.cluster_name}"
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.gw.id}"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }
}

resource "aws_launch_configuration" "master" {
  name_prefix          = "k8-master_${var.cluster_name}"
  image_id             = "${var.default_ami}"
  instance_type        = "${var.master_instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.master.name}"
  ebs_optimized        = "${var.master_ebs_optimized}"
  key_name             = "${var.key_name}"
  enable_monitoring    = false

  security_groups = [
    "${aws_security_group.master_to_master.id}",
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 40
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
