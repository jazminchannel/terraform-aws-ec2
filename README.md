# terraform-aws-ec2

Reusable EC2 instance module with secure defaults:
- IMDSv2 required
- Encrypted root volume
- Optional IAM role/instance profile
- Configurable SG ingress/egress
- Spot or On-Demand
- User data, extra EBS volumes, tags

See `examples/single-instance` to get started.

