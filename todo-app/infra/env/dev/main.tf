module "network" {
  source = "../../modules/network"

  project_settings = var.project_settings
  network_settings = var.network_settings
}

# ============================================
# デバッグモジュール
# ============================================
module "debug" {
  source = "../../modules/debug"

  project_settings       = var.project_settings
  enable_debug_resources = var.enable_debug_resources
  debug_settings = {
    vpc_id                = module.network.vpc.id
    vpc_cidr_block        = module.network.vpc.cidr_block
    rds_security_group_id = module.network.security_group_ids.rds
    ecs_private_subnet_id = module.network.subnet_ids.ecs[0]

    debug_subnet_cidr_block = var.debug_settings.debug_subnet_cidr_block
    availability_zone       = var.network_settings.availability_zones[0]
    private_route_table_ids = module.network.private_route_table_ids
  }
}

# ============================================
# Cognitoモジュール
# ============================================
module "cognito" {
  source           = "../../modules/cognito"
  project_settings = var.project_settings
}

# ============================================
# ECRモジュール
# ============================================
module "ecr" {
  source           = "../../modules/ecr"
  project_settings = var.project_settings
  ecr_settings     = var.ecr_settings
}

# ============================================
# RDSモジュール
# ============================================
module "rds" {
  source           = "../../modules/rds"
  project_settings = var.project_settings
  is_production    = var.is_production
  rds_settings = {
    rds_subnet_ids = module.network.subnet_ids.rds
    rds_sg_id      = module.network.security_group_ids.rds
    db_name        = var.rds_settings.db_name
    db_password    = var.rds_settings.db_password
    db_user        = var.rds_settings.db_user
    instance_type  = var.rds_settings.instance_type
  }
}

# ============================================
# ACM with validationモジュール
# ============================================
module "acm_with_validation" {
  source = "../../modules/acm_with_validation"

  project_settings = var.project_settings
  acm_settings = {
    zone_id     = var.domain_settings.zone_id
    domain_name = local.domain_name
  }

  providers = {
    aws      = aws
    aws.use1 = aws.use1
  }
}

# ============================================
# S3 ALB log モジュール
# ============================================
module "s3_alb_log" {
  source           = "../../modules/s3_alb_log"
  project_settings = var.project_settings
}

# ============================================
# ALB
# ============================================
module "alb" {
  source = "../../modules/alb"

  project_settings = var.project_settings
  alb_settings = {
    vpc_id          = module.network.vpc.id
    subnet_ids      = module.network.subnet_ids.alb
    sg_id           = module.network.security_group_ids.alb
    certificate_arn = module.acm_with_validation.api_cert_arn
    bucket_name     = module.s3_alb_log.bucket_name

    zone_id         = var.domain_settings.zone_id
    alb_domain_name = local.api_domain_name
  }
}
