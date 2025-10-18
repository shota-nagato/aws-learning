output "debug_ec2_instance_id" {
  value       = var.enable_debug_resources ? aws_instance.debug[0].id : null
  description = "デバッグ用EC2のインスタンスID"
}
