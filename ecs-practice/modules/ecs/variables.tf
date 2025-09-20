variable "common" {
  type = object({
    prefix             = string
    region             = string
    availability_zones = list(string)
  })
}

variable "network" {
  type = object({
    vpc_id                     = string
    public_subnet_ids          = list(string)
    security_group_frontend_id = string
  })
}

variable "alb_ingress" {
  type = object({
    alb_target_group_blue_arn        = string
    alb_target_group_green_arn       = string
    alb_listener_production_rule_arn = string
    alb_listener_test_rule_arn       = string
  })
}

variable "lambda_function_arn" {
  type = string
}
