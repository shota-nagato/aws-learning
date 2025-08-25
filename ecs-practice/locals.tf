locals {
  common = {
    prefix = "ecs-practice"
    env    = "dev"
    region = "ap-northeast-1"
  }

  network = {
    cidr = "172.16.0.0/16"
    subnet_groups = {
      public_ingress = {
        visibility = "public"
        tier       = "ingress"
        subnets = [
          {
            az   = "a"
            cidr = "172.16.1.0/24"
          },
          {
            az   = "c"
            cidr = "172.16.2.0/24"
          }
        ]
      }
      private_container = {
        visibility = "private"
        tier       = "container"
        subnets = [
          {
            az   = "a"
            cidr = "172.16.3.0/24"
          },
          {
            az   = "c"
            cidr = "172.16.4.0/24"
          }
        ]
      }
    }
  }
}
