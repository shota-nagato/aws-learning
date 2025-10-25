locals {
  domain_name = (
    var.domain_settings.domain_prefix != null
    ? "${var.domain_settings.domain_prefix}.${var.domain_settings.base_domain}"
    : var.domain_settings.base_domain
  )
}
