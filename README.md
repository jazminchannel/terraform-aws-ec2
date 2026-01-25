# Terraform AWS EC2 Module

This repository contains a reusable Terraform module for provisioning and managing Amazon EC2 instances in AWS. The module is designed to simplify EC2 deployments by providing configurable inputs for compute, networking, and security while promoting Infrastructure as Code best practices.

This module is suitable for learning, experimentation, and as a foundation for production-ready infrastructure when extended with environment-specific configurations.

---

## Features

- Provision EC2 instances using configurable parameters
- Support for custom AMIs and instance types
- Configurable VPC and subnet placement
- Security group association
- Tagging support for resource organization
- Modular design for reuse across environments

---

## Technologies Used

- Terraform
- Amazon Web Services (AWS)
  - EC2
  - VPC
  - Security Groups
  - IAM (instance profiles, if applicable)

---

## Module Inputs

| Name | Description | Type | Required |
|-----|------------|------|----------|
| instance_name | Name assigned to the EC2 instance | string | Yes |
| ami_id | AMI ID used to launch the instance | string | Yes |
| instance_type | EC2 instance type | string | Yes |
| subnet_id | Subnet ID where the instance will be deployed | string | Yes |
| vpc_id | VPC ID associated with the instance | string | Yes |
| security_group_ids | List of security group IDs | list(string) | Yes |
| key_name | SSH key pair name | string | No |
| tags | Additional resource tags | map(string) | No |

(Inputs may be extended as the module evolves.)

---

## Module Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the created EC2 instance |
| public_ip | Public IP address of the instance |
| private_ip | Private IP address of the instance |

---

## Example Usage

```hcl
module "ec2_instance" {
  source = "github.com/jazminchannel/terraform-aws-ec2"

  instance_name       = "example-ec2"
  ami_id              = "ami-0abcdef1234567890"
  instance_type       = "t3.micro"
  subnet_id           = "subnet-0123456789abcdef0"
  vpc_id              = "vpc-0123456789abcdef0"
  security_group_ids  = ["sg-0123456789abcdef0"]
  key_name            = "my-keypair"

  tags = {
    Environment = "dev"
    Project     = "terraform-ec2-module"
  }
}

