variable "project_settings" {
  type = object({
    project     = string
    environment = string
  })
}

variable "domain_settings" {
  type = object({
    domain_name = string
    zone_id     = string
  })
}

variable "bucket_regional_domain_name" {
  type = string
}

variable "bucket_origin_id" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}
