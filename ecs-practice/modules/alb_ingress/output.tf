output "alb_target_group_blue_arn" {
  value = aws_lb_target_group.blue.arn
}

output "alb_target_group_green_arn" {
  value = aws_lb_target_group.green.arn
}

output "alb_listener_production_rule_arn" {
  value = aws_lb_listener_rule.blue.arn
}

output "alb_listener_test_rule_arn" {
  value = aws_lb_listener_rule.green.arn
}
