resource "aws_ssm_parameter" "plain" {
  for_each = var.parameters

  name  = "${var.prefix}/${each.key}"
  type  = "String"
  value = each.value

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "secure" {
  for_each = var.secure_params

  name  = "${var.prefix}/${each.key}"
  type  = "SecureString"
  value = each.value

  lifecycle {
    ignore_changes = [value]
  }
}
