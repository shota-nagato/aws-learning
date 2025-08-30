variable "common" {
  type = object({
    prefix             = string
    region             = string
    availability_zones = list(string)
  })
}
