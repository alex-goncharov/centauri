resource "aws_iam_role" "worker" {
  name               = "k8_worker_node"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_trust.json}"
}

resource "aws_iam_instance_profile" "worker" {
  name = "k8_woker_node"
  role = "${aws_iam_role.worker.name}"
}

resource "aws_autoscaling_group" "worker" {
  tag {
    key                 = "Name"
    value               = "k8-worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "KubernetesCluster"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "role"
    value               = "k8worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "bunch"
    value               = "k8"
    propagate_at_launch = true
  }

  name                      = "k8-workers"
  vpc_zone_identifier       = ["${aws_subnet.main.*.id}"]
  max_size                  = "${var.worker_count}"
  min_size                  = "${var.worker_count}"
  health_check_grace_period = 900
  health_check_type         = "EC2"
  desired_capacity          = "${var.worker_count}"
  launch_configuration      = "${aws_launch_configuration.worker.name}"
}

resource "aws_security_group" "worker_to_worker" {
  name        = "worker_to_worker"
  description = "Allows traffic between workers"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name              = "worker_to_worker"
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

resource "aws_launch_configuration" "worker" {
  name_prefix          = "k8-worker_${var.cluster_name}"
  image_id             = "ami-81ab5ef8"
  instance_type        = "${var.worker_instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.worker.name}"
  ebs_optimized        = "${var.worker_ebs_optimized}"
  key_name             = "${var.key_name}"
  enable_monitoring    = false

  security_groups = [
    "${aws_security_group.worker_to_worker.id}",
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
