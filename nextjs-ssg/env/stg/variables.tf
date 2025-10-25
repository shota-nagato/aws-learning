variable "project_settings" {
  type = object({
    project     = string
    environment = string
  })
}

variable "domain_settings" {
  type = object({
    base_domain   = string
    domain_prefix = optional(string)
  })
}
