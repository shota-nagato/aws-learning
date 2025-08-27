locals {
  common = {
    prefix = "ecs-practice"
    env    = "dev"
    region = "ap-northeast-1"
  }

  network = {
    cidr = "10.0.0.0/20"
    subnet_groups = {
      app1 = {
        visibility = "private"
        subnets = [
          {
            az   = "a"
            cidr = "10.0.0.0/24"
          }
        ]
      },
      app2 = {
        visibility = "public"
        subnets = [
          {
            az   = "a"
            cidr = "10.0.1.0/24"
          }
        ]
      }
    }
  }
}
