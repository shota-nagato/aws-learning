terraform {
  backend "s3" {
    bucket         = "my-terraform-state-pcr6x7apmy"
    key            = "envs/shared/terraform.tfstate"
    region         = "ap-northeast-1"
    profile        = "default"
    use_lockfile   = true
    dynamodb_table = "taskfolio-terraform-locks"
  }
}
