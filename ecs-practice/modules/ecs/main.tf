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
