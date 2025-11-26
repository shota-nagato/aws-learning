resource "aws_iam_role" "lambda_role" {
  name = "sum-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "sum_function_code" {
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/build/sum_function.zip"
  type        = "zip"
}

resource "aws_lambda_function" "sum_function" {
  function_name = "sum-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.13"

  filename         = data.archive_file.sum_function_code.output_path
  source_code_hash = data.archive_file.sum_function_code.output_base64sha256
}

resource "aws_lambda_permission" "invoke_from_cdn" {
  function_name = aws_lambda_function.sum_function.function_name
  statement_id  = "AllowFromCloudFront"
  action        = "lambda:InvokeFunctionUrl"
  principal     = "cloudfront.amazonaws.com"

  source_arn = aws_cloudfront_distribution.cf_distribution.arn
}

resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.sum_function.function_name
  authorization_type = "AWS_IAM"
}

resource "aws_cloudwatch_log_group" "lambda_url" {
  name              = "/aws/lambda/${aws_lambda_function.sum_function.function_name}"
  retention_in_days = 7
}
