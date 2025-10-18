terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
  default_tags {
    tags = {
      Project     = "taskfolio"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

provider "aws" {
  alias   = "use1"
  region  = "us-east-1"
  profile = "default"
}
