output "public_ips" {
  description = "A list of public IPs for the created EC2 instances."
  value       = [for instance in aws_instance.public : instance.public_ip]
}
