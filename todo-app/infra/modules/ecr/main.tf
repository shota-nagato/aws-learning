locals {
  prefix = "${var.project_settings.project}-${var.project_settings.environment}"
}

# ============================================
# ECR
# ============================================
resource "aws_ecr_repository" "repository" {
  name                 = "${local.prefix}-ecr-api"
  image_tag_mutability = var.project_settings.environment == "prod" ? "IMMUTABLE" : "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep branch-tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["${var.project_settings.environment}-"]
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = var.ecr_settings.retention_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
