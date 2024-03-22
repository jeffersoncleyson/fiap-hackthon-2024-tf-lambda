# Input variable definitions

variable "application_name" {
  description = "Application name"
  type        = string
}

variable "lambda_name" {
  description = "Lambda name"
  type        = string
}

variable "lambda_layer_arn" {
  description = "Lambda Layer ARN"
  type        = string
}

variable "path_lambda" {
  description = "Path Lambda"
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda Runtime name"
  type        = string
}

variable "lambda_handler" {
  description = "Lambda Handler name"
  type        = string
}

variable "lambda_environments" {
  description = "Environment variables"
  type        = map(string)
  default = {
    key: "value"
  }
}

variable "vpc_public_subnets" {
  description = "VPC Public Subnets"
  type        = list(any)
}

variable "vpc_sg_id" {
  description = "VPC Security Group"
  type        = string
}
