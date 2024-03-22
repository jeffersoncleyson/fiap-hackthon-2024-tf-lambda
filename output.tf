# Output value definitions

############################################### [S3|Lambda] Outputs

output "function_url" {
  description = "URL Lambda function."

  value = aws_lambda_function_url.lambda_url.function_url
}

output "function_invoke_arn" {
  description = "Arn Lambda function."

  value = aws_lambda_function.lambda_func.invoke_arn
}

output "function_name" {
  description = "Name Lambda function."

  value = aws_lambda_function.lambda_func.function_name
}


###############################################
