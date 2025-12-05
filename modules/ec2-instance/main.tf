locals {
  merged_tags = merge(
    {
      "ManagedBy" = "Terraform"
      "Module"    = "ec2-instance"
    },
    var.tags
  )
}

# Optional IAM role + instance profile
resource "aws_iam_role" "this" {
  count = var.create_iam_role ? 1 : 0

  name               = var.iam_role_name != null ? var.iam_role_name : "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
  tags               = local.merged_tags
}

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.name}-instance-profile"
  role  = aws_iam_role.this[0].name
  tags  = local.merged_tags
}

# Security Group
resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id
  tags        = local.merged_tags
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = { for r in var.ingress_rules : "${r.protocol}-${r.from_port}-${r.to_port}-${r.cidr_block}" => r }

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value.cidr_block
  ip_protocol       = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  description       = coalesce(try(each.value.description, null), "ingress")
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "all egress"
}

# Optional key pair (or pass an existing name)
resource "aws_key_pair" "this" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.key_name != null ? var.key_name : "${var.name}-key"
  public_key = var.public_key
  tags       = local.merged_tags
}

# Launch template for flexibility (spot/on-demand, metadata, volumes, userdata)
resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  update_default_version = true

  iam_instance_profile {
    name = var.create_iam_role ? aws_iam_instance_profile.this[0].name : var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip
    security_groups             = [aws_security_group.this.id]
    subnet_id                   = var.subnet_id
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"     # IMDSv2 required
    http_put_response_hop_limit = 2
  }

  monitoring {
    enabled = var.detailed_monitoring
  }

  user_data = var.user_data_base64

  block_device_mappings {
    device_name = var.root_block_device.device_name
    ebs {
      volume_size = var.root_block_device.volume_size
      volume_type = var.root_block_device.volume_type
      encrypted   = true
      kms_key_id  = var.root_block_device.kms_key_id
      iops        = var.root_block_device.iops
      throughput  = var.root_block_device.throughput
      delete_on_termination = true
    }
  }

  dynamic "block_device_mappings" {
    for_each = var.extra_ebs_volumes
    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = block_device_mappings.value.volume_type
        encrypted             = true
        kms_key_id            = block_device_mappings.value.kms_key_id
        iops                  = try(block_device_mappings.value.iops, null)
        throughput            = try(block_device_mappings.value.throughput, null)
        delete_on_termination = true
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.merged_tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.merged_tags
  }

  tags = local.merged_tags
}

# Single instance via Launch Template (not ASG)
resource "aws_instance" "this" {
  count = var.instance_count

  ami           = aws_launch_template.this.image_id
  instance_type = aws_launch_template.this.instance_type
  subnet_id     = var.subnet_id

  key_name = var.create_key_pair ? aws_key_pair.this[0].key_name : var.key_name

  vpc_security_group_ids = [aws_security_group.this.id]
  associate_public_ip_address = var.associate_public_ip

  iam_instance_profile = var.create_iam_role ? aws_iam_instance_profile.this[0].name : var.instance_profile_name

  user_data = var.user_data

  monitoring = var.detailed_monitoring

  root_block_device {
    volume_size = var.root_block_device.volume_size
    volume_type = var.root_block_device.volume_type
    encrypted   = true
    kms_key_id  = var.root_block_device.kms_key_id
    iops        = var.root_block_device.iops
    throughput  = var.root_block_device.throughput
  }

  tags = merge(local.merged_tags, { "Name" = "${var.name}-${count.index}" })
}

