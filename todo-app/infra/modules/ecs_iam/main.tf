data "aws_kms_key" "ssm_default" {
  key_id = "alias/aws/ssm"
}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  prefix = "${var.project_settings.project}-${var.project_settings.environment}"
}

resource "aws_iam_policy" "ssm_read" {
  name = "${local.prefix}-ssm-read-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParameterHistory"
      ]
      Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.ecs_iam_settings.ssm_prefix}/*"
    }]
  })
}

resource "aws_iam_policy" "kms_decrypt" {
  name = "${local.prefix}-kms-decrypt-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:Decrypt"
      ]
      Resource = [data.aws_kms_key.ssm_default.arn]
    }]
  })
}

resource "aws_iam_role" "ecs_exec" {
  name = "${local.prefix}-ecs-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "${local.prefix}-ecs-exec-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_exec_task_execution" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_exec_ssm_read" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = aws_iam_policy.ssm_read.arn
}
