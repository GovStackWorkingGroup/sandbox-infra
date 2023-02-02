variable "lambdaName" {
    type = string
}

variable "bucketID" {
    type = string
}

variable "cognitoPoolArn" {
  type = string
}

variable "lambdaRoleArn" {
    type = string
}

variable "env_vars" {
    type = map
    default = {}
}

#split the friendly name of the role from the arn for policy attachment
locals {
  role_split = split("/", var.lambdaRoleArn)
  role_name = local.role_split[length(local.role_split) - 1]

  work_dir = "${path.module}/functions/${var.lambdaName}"
}

resource "null_resource" "lambda_package" {

  provisioner "local-exec" {
    command = "npm install; tsc"
    working_dir = local.work_dir
    on_failure = continue
 }

  triggers = {
    index = sha256(file("${var.lambdaName}.ts"))
    package = sha256(file("package.json"))
    tsconfig = sha256(file("tsconfig.json"))
    # modify ="yes" # change value when you want to force this
  }
}

# Zip the lambda code and put it in the s3 bucket
data "archive_file" "lambda_archive" {
    type = "zip"
    source_dir = local.work_dir
    output_path = "${local.work_dir}/${var.lambdaName}.zip"

    excludes = [ 
      "${var.lambdaName}.ts",
      "package.json",
      "package-lock.json",
      "tsconfig.json",
      "${var.lambdaName}.zip"
     ]

  depends_on = [
    null_resource.lambda_package
  ]
}



resource "aws_s3_object" "lambda_source_object" {
    bucket = var.bucketID
    key = "${var.lambdaName}.zip"
    source = data.archive_file.lambda_archive.output_path

    source_hash = data.archive_file.lambda_archive.output_base64sha256

    depends_on = [
      data.archive_file.lambda_archive
    ]
}

# Create function
 resource "aws_lambda_function" "CognitoLambda" {
    s3_bucket = var.bucketID
    s3_key = aws_s3_object.lambda_source_object.id
    role = var.lambdaRoleArn
    runtime = "nodejs16.x"

    source_code_hash = "${var.lambdaName}.zip"

    handler = "${var.lambdaName}.handler"

    function_name = "${var.lambdaName}Lambda"
    environment {
      variables = var.env_vars
    }
    depends_on = [
      aws_s3_object.lambda_source_object
    ]
 }

# Allow cognito trigger the lambda
 resource "aws_lambda_permission" "cognito_invocation_permission" {
  statement_id = "Allow${var.lambdaName}LambdaInvokeCognito"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.CognitoLambda.function_name
  principal = "cognito-idp.amazonaws.com"
  source_arn = var.cognitoPoolArn
}

# Lambda Log group and permissions to put logs 
resource "aws_cloudwatch_log_group" "lambda_log_group" {
    name              = "/aws/lambda/${var.lambdaName}Lambda"
    retention_in_days = 14
}

data "aws_iam_policy_document" "lambda_logging_policy_document" {
  statement {
    sid = "LambdaLogroup"
    actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]
    resources = [
        aws_cloudwatch_log_group.lambda_log_group.arn
      ]
  }
}

resource "aws_iam_policy" "lamda_logging_policy" {
  name   = "Allow${var.lambdaName}LoggingPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_logging_policy_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role = local.role_name
  policy_arn = aws_iam_policy.lamda_logging_policy.arn
  depends_on = [
    aws_iam_policy.lamda_logging_policy
  ]
}

output "lambda_arn" {
  value = aws_lambda_function.CognitoLambda.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.CognitoLambda.invoke_arn
  
}