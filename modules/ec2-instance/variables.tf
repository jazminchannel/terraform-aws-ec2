variable "name" {
  description = "Base name for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "ami_id" {
  description = "AMI to launch"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "associate_public_ip" {
  description = "Associate a public IP"
  type        = bool
  default     = false
}

variable "ingress_rules" {
  description = "List of ingress rule objects"
  type = list(object({
    protocol    = string # "tcp" | "udp" | "-1"
    from_port   = number
    to_port     = number
    cidr_block  = string
    description = optional(string)
  }))
  default = []
}

variable "detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "User data (plain text). If provided, user_data_base64 will be ignored."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "User data (base64-encoded). Used only if user_data is null."
  type        = string
  default     = null
}

variable "root_block_device" {
  description = "Root EBS configuration"
  type = object({
    device_name = string
    volume_size = number
    volume_type = string
    kms_key_id  = optional(string)
    iops        = optional(number)
    throughput  = optional(number)
  })
  default = {
    device_name = "/dev/xvda"
    volume_size = 20
    volume_type = "gp3"
  }
}

variable "extra_ebs_volumes" {
  description = "Additional EBS volumes"
  type = list(object({
    device_name = string
    volume_size = number
    volume_type = string
    kms_key_id  = optional(string)
    iops        = optional(number)
    throughput  = optional(number)
  }))
  default = []
}

variable "create_key_pair" {
  description = "Whether to create a key pair from provided public_key"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Existing key pair name; ignored if create_key_pair = true"
  type        = string
  default     = null
}

variable "public_key" {
  description = "Public key material if create_key_pair = true"
  type        = string
  default     = null
}

variable "create_iam_role" {
  description = "Create IAM role & instance profile"
  type        = bool
  default     = false
}

variable "iam_role_name" {
  description = "Custom IAM role name if creating"
  type        = string
  default     = null
}

variable "instance_profile_name" {
  description = "Existing instance profile name (used if create_iam_role = false)"
  type        = string
  default     = null
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}

