data "aws_region" "current" {}

locals {
  prefix = "${var.project_settings.project}-${var.project_settings.environment}"
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.project_settings.project}/${var.project_settings.environment}/api"
  retention_in_days = 7
  tags = {
    Name = "${local.prefix}-ecs-execution-api-log-group"
  }
}

resource "aws_ecs_cluster" "this" {
  name = "${local.prefix}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name = "${local.prefix}-ecs-cluster"
  }
}

resource "aws_ecs_task_definition" "api" {
  family = "${local.prefix}-ecs-api-task"

  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  cpu    = "512"
  memory = "1024"

  execution_role_arn = var.ecs_settings.ecs_execution_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  lifecycle {
    ignore_changes = [container_definitions]
  }

  container_definitions = jsonencode([
    {
      name      = "api"
      image     = "${var.ecs_settings.ecr_repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        },
      ]
      secrets = [
        {
          name      = "DB_HOST"
          valueFrom = "${var.ssm_parameters.db_host_name}"
        },
        {
          name      = "DB_USER"
          valueFrom = "${var.ssm_parameters.db_user}"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.ssm_parameters.db_password}"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${var.ssm_parameters.db_name}"
        },
        {
          name      = "CORS_ORIGIN"
          valueFrom = "${var.ssm_parameters.origin_url}"
        },
        {
          name      = "COGNITO_CLIENT_ID"
          valueFrom = "${var.ssm_parameters.cognito_client_id}"
        },
        {
          name      = "COGNITO_USER_POOL_ID"
          valueFrom = "${var.ssm_parameters.cognito_user_pool_id}"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.api.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "${local.prefix}-api"
        }
      }
    }
  ])

  tags = {
    Name = "${local.prefix}-ecs-task-definition-api"
  }
}

resource "aws_ecs_service" "api" {
  name            = "${local.prefix}-ecs-api-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.api.arn

  desired_count = 1
  launch_type   = "FARGATE"

  lifecycle {
    ignore_changes = [task_definition]
  }

  network_configuration {
    subnets          = var.ecs_settings.ecs_subnet_ids
    security_groups  = [var.ecs_settings.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.ecs_settings.alb_target_group_arn
    container_name   = "api"
    container_port   = 8080
  }

  tags = {
    Name = "${local.prefix}-ecs-api-service"
  }
}
