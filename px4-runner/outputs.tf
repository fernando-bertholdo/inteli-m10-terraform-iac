output "instance_id" {
  description = "ID da EC2 do runner"
  value       = aws_instance.px4_runner.id
}

output "public_ip" {
  description = "IP publico para SSH (administracao do runner)"
  value       = aws_instance.px4_runner.public_ip
}

output "ami_id" {
  description = "AMI Ubuntu 24.04 resolvida dinamicamente pelo data source"
  value       = data.aws_ami.ubuntu.id
}
