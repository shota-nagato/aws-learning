resource "aws_ecs_cluster" "main" {
  name = "${var.common.prefix}-cluster"
}

resource "aws_ecs_task_definition" "service" {
  family = "${var.common.prefix}-frontend"

  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "public.ecr.aws/nginx/nginx:1.28-alpine3.21-slim"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.frontend.name
          awslogs-region        = var.common.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "frontend" {
  name                               = "${var.common.prefix}-frontend"
  cluster                            = aws_ecs_cluster.main.arn
  task_definition                    = aws_ecs_task_definition.service.arn
  launch_type                        = "FARGATE"
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_controller {
    type = "ECS"
  }

  deployment_configuration {
    strategy             = "BLUE_GREEN"
    bake_time_in_minutes = 2
  }

  network_configuration {
    subnets = var.network.public_subnet_ids
    security_groups = [
      var.network.security_group_frontend_id
    ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.alb_ingress.alb_target_group_blue_arn
    container_name   = "frontend"
    container_port   = 80

    advanced_configuration {
      alternate_target_group_arn = var.alb_ingress.alb_target_group_green_arn
      production_listener_rule   = var.alb_ingress.alb_listener_production_rule_arn
      test_listener_rule         = var.alb_ingress.alb_listener_test_rule_arn
      role_arn                   = aws_iam_role.ecs_infrastructure_role_for_load_balancers.arn
    }
  }
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${var.common.prefix}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${var.common.prefix}-frontend"
  retention_in_days = 14

  tags = {
    Name = "/ecs/${var.common.prefix}-frontend"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_exec_task_execution" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_infrastructure_role_for_load_balancers" {
  name = "ecsInfrastructureRoleForLoadBalancers"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "AllowAccessToECSForInfrastructureManagement",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_infrastructure_role_for_load_balancers_attachment" {
  role       = aws_iam_role.ecs_infrastructure_role_for_load_balancers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSInfrastructureRolePolicyForLoadBalancers"
}
