variable "common" {
  type = object({
    env    = string
    prefix = string
    region = string
  })
}

variable "network" {
  type = object({
    cidr = string
    subnet_groups = map(object({
      visibility = string
      subnets = list(object({
        az   = string
        cidr = string
      }))
    }))
  })
}
