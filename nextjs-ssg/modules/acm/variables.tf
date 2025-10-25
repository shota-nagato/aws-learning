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
