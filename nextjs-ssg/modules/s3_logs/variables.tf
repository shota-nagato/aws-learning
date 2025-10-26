variable "project_settings" {
  type = object({
    project     = string
    environment = string
  })
}
