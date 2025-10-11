# ============================================
# プロジェクト共通の設定
# ============================================
variable "project_settings" {
  description = "プロジェクト共通の設定"
  type = object({
    project     = string
    environment = string
  })
}

variable "domain_name" {
  description = "ドメイン名。例: example.com"
  type        = string
}
