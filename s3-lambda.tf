resource "random_pet" "lambda_bucket_name" {
  prefix = var.lambda_name
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = random_pet.lambda_bucket_name.id
  force_destroy = true

  tags = {
    App = var.application_name,
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.lambda_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
  bucket     = aws_s3_bucket.lambda_bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

data "archive_file" "lambda_file" {
  type = "zip"

  excludes = [
    "dependencies"
  ]
  source_dir  = "${path.root}/${var.path_lambda}/${var.lambda_name}"
  output_path = "${path.root}/${var.path_lambda}/zip-files/${var.lambda_name}-lambda.zip"

}

resource "aws_s3_object" "s3_lambda_obj" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "${var.lambda_name}-lambda.zip"
  source = data.archive_file.lambda_file.output_path

  etag = filemd5(data.archive_file.lambda_file.output_path)

  tags = {
    App = var.application_name,
  }
}