locals {
  name_prefix = "${var.project_settings.project}-${var.project_settings.environment}-${var.project_settings.developer}"
}

resource "aws_cognito_user_pool" "this" {
  name = "${local.name_prefix}-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false
    require_uppercase                = false
    temporary_password_validity_days = 7
  }

  # アカウントリカバリー設定
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = {
    Name = "${local.name_prefix}-user-pool"
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${local.name_prefix}-app-client"
  user_pool_id = aws_cognito_user_pool.this.id

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = false

  # Reactのaws-amplify/authライブラリで使用する認証フローを明示
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",      # パスワードログイン
    "ALLOW_REFRESH_TOKEN_AUTH", # トークン更新
    "ALLOW_CUSTOM_AUTH",        # カスタム認証
    "ALLOW_USER_PASSWORD_AUTH"  # username & password認証
  ]

  # IDプロバイダーの指定
  supported_identity_providers = ["COGNITO"]

  prevent_user_existence_errors = "ENABLED"
}

resource "aws_cognito_user_group" "admin" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.this.id
  description  = "管理者ユーザーグループ"
}

output "COGNITO_USER_POOL_ID" {
  description = "CognitoユーザープールID"
  value       = aws_cognito_user_pool.this.id
}

output "COGNITO_CLIENT_ID" {
  description = "CognitoユーザープールクライアントID"
  value       = aws_cognito_user_pool_client.this.id
}
