output "debug_ec2_instance_id" {
  value       = module.debug.debug_ec2_instance_id
  description = "Instance ID of debug EC2 for SSM Session Manager"
}

output "ECR_REPOSITORY" {
  value = module.ecr.repository_name
}

output "rds_endpoint" {
  value       = module.rds.db_instance_address
  description = "RDS接続のエンドポイント"
}

output "ECS_CLUSTER" {
  value = module.ecs.cluster_name
}

output "ECS_SERVICE" {
  value = module.ecs.service_name
}

output "GITHUB_ROLE" {
  value = module.cicd_iam.github_actions_role_arn
}
