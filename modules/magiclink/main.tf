resource "aws_api_gateway_rest_api" "PortalRestApi" {
  
  name = "Sandbox-${var.product}-${var.environment}-SignIn-Api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "PortalApiResource" {
  path_part   = "signIn"
  parent_id   = aws_api_gateway_rest_api.PortalRestApi.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.PortalRestApi.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.PortalRestApi.id
  resource_id   = aws_api_gateway_resource.PortalApiResource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.PortalRestApi.id
  resource_id             = aws_api_gateway_resource.PortalApiResource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.signIn.lambda_invoke_arn
}

data "aws_caller_identity" "current" {}

locals {
    account = data.aws_caller_identity.current.account_id
}

resource "aws_ses_email_identity" "ses_from_address" {
  email = var.ses_from_address
}