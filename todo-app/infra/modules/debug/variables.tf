variable "project_settings" {
  description = "プロジェクト共通の設定"
  type = object({
    project     = string
    environment = string
  })
}

variable "enable_debug_resources" {
  description = "デバック用リソースを作成するかどうか"
  type        = bool
  default     = false
}

variable "debug_settings" {
  description = "デバッグ用のリソース設定"
  type = object({
    vpc_id                  = string
    vpc_cidr_block          = string
    debug_subnet_cidr_block = string
    availability_zone       = string
    rds_security_group_id   = string
    ecs_private_subnet_id   = string
  })
}
