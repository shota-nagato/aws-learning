data "archive_file" "lambda_function" {
  type        = "zip"
  source_dir  = "${path.root}/lambda"
  output_path = "${path.root}/lambda/function.zip"
}

resource "aws_lambda_function" "lifecycle_hooks" {
  function_name = "${var.common.prefix}-lifecycle-hooks"
  role          = aws_iam_role.lambda_exec_role.arn
  filename      = data.archive_file.lambda_function.output_path
  handler       = "function.lambda_handler"
  runtime       = "python3.13"
  timeout       = 60

  source_code_hash = data.archive_file.lambda_function.output_base64sha256
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.common.prefix}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
