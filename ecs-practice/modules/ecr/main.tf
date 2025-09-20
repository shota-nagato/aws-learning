resource "aws_ecr_repository" "frontend" {
  name                 = "${var.common.prefix}-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}
