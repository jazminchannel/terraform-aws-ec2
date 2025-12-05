terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "us-east-1"
}

# Simple user data example
locals {
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    echo "Hello from $(hostname)" > /etc/motd
  EOF
}

module "ec2" {
  source = "../../modules/ec2-instance"

  name             = "demo-ec2"
  vpc_id           = var.vpc_id
  subnet_id        = var.subnet_id
  ami_id           = var.ami_id
  instance_type    = "t3.micro"
  associate_public_ip = true

  ingress_rules = [
    { protocol = "tcp", from_port = 22, to_port = 22, cidr_block = "0.0.0.0/0", description = "SSH" },
    { protocol = "tcp", from_port = 80, to_port = 80, cidr_block = "0.0.0.0/0", description = "HTTP" }
  ]

  user_data = local.user_data

  root_block_device = {
    device_name = "/dev/xvda"
    volume_size = 16
    volume_type = "gp3"
  }

  # Use an existing key pair:
#  key_name = "my-existing-keypair"

  # Or create one from a public key:
  create_key_pair = true
  public_key      = file("~/.ssh/id_rsa_jgit.pub")

  # Create IAM role automatically or pass an existing instance profile name
  create_iam_role        = true
  instance_profile_name  = null

  tags = {
    Project = "Demo"
    Env     = "dev"
  }
}

output "instance_ids" {
  value = module.ec2.instance_ids
}
output "public_ips" {
  value = module.ec2.public_ips
}

