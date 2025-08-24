variable "common" {
  type = object({
    env    = string
    prefix = string
    region = string
  })
}
