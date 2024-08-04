terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

locals {
  region = "us-east-1"
  accountId = "446923752902"
}

# Create the AWS Lambda functions / S3 Resources
data "aws_s3_object" "async" {
  bucket = "inmoment.codestore"
  key    = "async.zip"
}

resource "aws_lambda_function" "inmoment_teraform_async" {
  function_name    = "inmoment_terraform_async"
  s3_bucket        = "inmoment.codestore"
  s3_key           = "async.zip"
    architectures    = ["arm64"]
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = "512"
  timeout          = "900"
  role             = "arn:aws:iam::446923752902:role/service-role/inmoment_aync_creator-role-lrik0k0m"
  source_code_hash = data.aws_s3_object.async.etag
}

data "aws_s3_object" "metrics" {
  bucket = "inmoment.codestore"
  key    = "metrics.zip"
}

resource "aws_lambda_function" "inmoment_teraform_metrics" {
  function_name    = "inmoment_terraform_metrics"
    architectures    = ["arm64"]
  s3_bucket        = "inmoment.codestore"
  s3_key           = "metrics.zip"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = "512"
  timeout          = "900"
  role             = "arn:aws:iam::446923752902:role/service-role/inmoment_aync_creator-role-lrik0k0m"
   
  file_system_config {
    # EFS file system access point ARN
    arn = aws_efs_access_point.access_point_for_lambda.arn

    # Local mount path inside the lambda function. Must start with '/mnt/'.
    local_mount_path = "/mnt/efs"
  }

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = ["subnet-17794270"]
    security_group_ids = ["sg-89c621db"]
  }

  # Explicitly declare dependency on EFS mount target.
  # When creating or updating Lambda functions, mount target must be in 'available' lifecycle state.
  depends_on = [aws_efs_mount_target.alpha]
  source_code_hash = data.aws_s3_object.metrics.etag
}

data "aws_s3_object" "reporter" {
  bucket = "inmoment.codestore"
  key    = "reporter.zip"
}

resource "aws_lambda_function" "inmoment_teraform_reporter" {
  function_name    = "inmoment_terraform_reporter"
  architectures    = ["arm64"]
  s3_bucket        = "inmoment.codestore"
  s3_key           = "reporter.zip"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = "512"
  timeout          = "900"
  role             = aws_iam_role.role.arn
 
  file_system_config {
    # EFS file system access point ARN
    arn = aws_efs_access_point.access_point_for_lambda.arn

    # Local mount path inside the lambda function. Must start with '/mnt/'.
    local_mount_path = "/mnt/efs"
  }

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = ["subnet-17794270"]
    security_group_ids = ["sg-89c621db"]
  }

  # Explicitly declare dependency on EFS mount target.
  # When creating or updating Lambda functions, mount target must be in 'available' lifecycle state.
  depends_on = [aws_efs_mount_target.alpha]
  source_code_hash = data.aws_s3_object.check.etag
}

data "aws_s3_object" "check" {
  bucket = "inmoment.codestore"
  key    = "check.zip"
}

resource "aws_lambda_function" "inmoment_teraform_check" {
  function_name    = "inmoment_terraform_check"
  architectures    = ["arm64"]
  s3_bucket        = "inmoment.codestore"
  s3_key           = "check.zip"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = "512"
  timeout          = "900"
  role             = "arn:aws:iam::446923752902:role/service-role/inmoment_aync_creator-role-lrik0k0m"
 
  file_system_config {
    # EFS file system access point ARN
    arn = aws_efs_access_point.access_point_for_lambda.arn

    # Local mount path inside the lambda function. Must start with '/mnt/'.
    local_mount_path = "/mnt/efs"
  }

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = ["subnet-17794270"]
    security_group_ids = ["sg-89c621db"]
  }

  # Explicitly declare dependency on EFS mount target.
  # When creating or updating Lambda functions, mount target must be in 'available' lifecycle state.
  depends_on = [aws_efs_mount_target.alpha]
  source_code_hash = data.aws_s3_object.check.etag
}

# EFS file system
resource "aws_efs_file_system" "inmoment_efs_for_lambda" {
  tags = {
    Name = "inmoment_efs_for_lambda"
  }
}

# Mount target connects the file system to the subnet
resource "aws_efs_mount_target" "alpha" {
  file_system_id  = aws_efs_file_system.inmoment_efs_for_lambda.id
  subnet_id       = "subnet-17794270"
  security_groups = ["sg-89c621db"]
}

# EFS access point used by lambda file system
resource "aws_efs_access_point" "access_point_for_lambda" {
  file_system_id = aws_efs_file_system.inmoment_efs_for_lambda.id

  root_directory {
    path = "/efs"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "777"
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }
}

# Create API Gateway
resource "aws_api_gateway_rest_api" "example" {
  name        = "InMomentExample"
}

# Async
resource "aws_api_gateway_resource" "async" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  parent_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  path_part   = "async"
}

resource "aws_api_gateway_method" "async" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_resource.async.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "inmoment_teraform_async" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  resource_id = "${aws_api_gateway_method.async.resource_id}"
  http_method = "${aws_api_gateway_method.async.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.inmoment_teraform_async.invoke_arn}"
}

# Reporter
resource "aws_api_gateway_resource" "reporter" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  parent_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  path_part   = "reporter"
}

resource "aws_api_gateway_method" "reporter" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_resource.reporter.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "inmoment_teraform_reporter" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  resource_id = "${aws_api_gateway_method.reporter.resource_id}"
  http_method = "${aws_api_gateway_method.reporter.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.inmoment_teraform_reporter.invoke_arn}"
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    aws_api_gateway_integration.inmoment_teraform_async,
    aws_api_gateway_integration.inmoment_teraform_reporter,
    # "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  stage_name  = "test"
}

# IAM
resource "aws_lambda_permission" "apigw_lambda_async" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.inmoment_teraform_async.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${local.region}:${local.accountId}:${aws_api_gateway_rest_api.example.id}/*/${aws_api_gateway_method.async.http_method}${aws_api_gateway_resource.async.path}"
}

resource "aws_lambda_permission" "apigw_lambda_reporter" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.inmoment_teraform_reporter.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${local.region}:${local.accountId}:${aws_api_gateway_rest_api.example.id}/*/${aws_api_gateway_method.reporter.http_method}${aws_api_gateway_resource.reporter.path}"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = "myrole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}