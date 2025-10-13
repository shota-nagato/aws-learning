variable "project_settings" {
  description = "プロジェクト共通の設定"
  type = object({
    project     = string
    environment = string
  })
}

variable "alb_settings" {
  description = "ALB用の設定"
  type = object({
    vpc_id          = string
    zone_id         = string
    subnet_ids      = list(string)
    sg_id           = string
    certificate_arn = string
    alb_domain_name = string
    bucket_name     = string
  })
}
