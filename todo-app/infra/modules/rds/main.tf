locals {
  prefix = "${var.project_settings.project}-${var.project_settings.environment}"
}

# ============================================
# RDS
# ============================================
resource "aws_db_instance" "this" {
  identifier = "${local.prefix}-postgresql-rds"

  engine            = "postgres"
  engine_version    = "16.9"
  instance_class    = var.rds_settings.instance_type
  allocated_storage = 20
  storage_type      = "gp3"

  # 管理者ユーザー情報
  username = var.rds_settings.db_user
  password = var.rds_settings.db_password
  db_name  = var.rds_settings.db_name
  port     = 5432

  # ネットワーク設定
  vpc_security_group_ids = [var.rds_settings.rds_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name

  # パラメータグループ
  parameter_group_name = aws_db_parameter_group.parameter_group.name

  # 削除防止設定
  deletion_protection = var.is_production

  # 実務ではfalse推奨
  skip_final_snapshot = true

  # 設定をすぐに範囲するか
  apply_immediately = !var.is_production

  # マルチAZ構成
  multi_az = var.is_production

  publicly_accessible = false

  # ストレージのデータを暗号化する
  storage_encrypted = true

  # バックアップ時間
  backup_window = "18:00-19:00"

  # 定期メンテナンス時間
  maintenance_window = "Sun:04:00-Sun:05:00"

  # バックアップ保持期間
  backup_retention_period = var.is_production ? 7 : 1

  # スナップショットにタグをコピーするか
  copy_tags_to_snapshot = true

  lifecycle {
    prevent_destroy = false

    ignore_changes = [final_snapshot_identifier]
  }

  tags = {
    Name = "${local.prefix}-postgresql-rds"
  }
}

# Subnet group
resource "aws_db_subnet_group" "subnet_group" {
  name = "${local.prefix}-postgresql-subnet-group"

  subnet_ids = var.rds_settings.rds_subnet_ids

  tags = {
    Name = "${local.prefix}-postgresql-subnet-group"
  }
}

# Parameter group
resource "aws_db_parameter_group" "parameter_group" {
  name = "${local.prefix}-postgresql-parameter-group"

  family      = "postgres16"
  description = "postgresql parameter group"

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = {
    Name = "${local.prefix}-postgresql-parameter-group"
  }
}
