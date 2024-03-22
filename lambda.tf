resource "aws_iam_role" "lambda_exec" {
  name = "serverless_${var.lambda_name}_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })

  tags = {
    App = var.application_name,
  }
}

resource "aws_lambda_function" "lambda_func" {
  function_name = var.lambda_name

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.s3_lambda_obj.key

  runtime     = var.lambda_runtime
  handler     = var.lambda_handler
  memory_size = 128

  source_code_hash = data.archive_file.lambda_file.output_base64sha256

  layers = [
    var.lambda_layer_arn
  ]

  role = aws_iam_role.lambda_exec.arn

  vpc_config {
    subnet_ids         = var.vpc_public_subnets
    security_group_ids = ["${var.vpc_sg_id}"]
  }

  environment {
    variables = var.lambda_environments
  }

  tags = {
    App = var.application_name,
  }
}

resource "aws_cloudwatch_log_group" "cloud_watch_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_func.function_name}"
  retention_in_days = 1
  

  tags = {
    App = var.application_name,
  }
}

resource "aws_iam_role_policy" "service" {
  name = "${var.lambda_name}_role_policy"
  role = aws_iam_role.lambda_exec.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "ec2:*",
        "ses:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.lambda_func.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}
