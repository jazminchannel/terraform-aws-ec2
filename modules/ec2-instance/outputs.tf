output "security_group_id" {
  value = aws_security_group.this.id
}

output "instance_ids" {
  value = [for i in aws_instance.this : i.id]
}

output "private_ips" {
  value = [for i in aws_instance.this : i.private_ip]
}

output "public_ips" {
  value = [for i in aws_instance.this : i.public_ip]
}

output "iam_instance_profile_name" {
  value = try(aws_iam_instance_profile.this[0].name, null)
}

