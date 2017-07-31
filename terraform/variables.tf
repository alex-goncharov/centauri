variable cluster_name {
  default = "centauri"
}

variable vpc_cidr_block {
  default = "192.168.0.0/20"
}

variable cluster_ip_plan {
  type = "list"

  default = [
    {
      az     = "eu-west-1a"
      subnet = "192.168.0.0/24"
    },
    {
      az     = "eu-west-1b"
      subnet = "192.168.1.0/24"
    },
    {
      az     = "eu-west-1c"
      subnet = "192.168.2.0/24"
    },
  ]
}

variable gw_subnet {
  default = "192.168.15.0/24"
}

variable master_count {
  default = 3
}

variable default_ami {
  // Ubuntu 16.04 LTS EBS HVM
  default = "ami-6d48500b"
}

variable master_instance_type {
  default = "t2.medium"
}

variable master_ebs_optimized {
  default = false
}

variable key_name {
  default = "agoncharov"
}

variable worker_count {
  default = 3
}

variable worker_instance_type {
  default = "t2.medium"
}

variable worker_ebs_optimized {
  default = false
}
