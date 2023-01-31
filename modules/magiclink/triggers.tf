# S3 bucket for lambda functions
resource "aws_s3_bucket" "lamdbabucket" {
  bucket = "govstack-${var.environment}-${var.product}-functions-bucket"
}

module "createAuthChallenge" {
  source = "..//cognitolambda"

  lambdaName = "createAuthChallenge"
  bucketID = aws_s3_bucket.lamdbabucket.id
  cognitoPoolArn = aws_cognito_user_pool.sandbox_userpool.arn
  lambdaRoleArn = aws_iam_role.createAuth_lambda_iam_role.arn
}

module "defineAuthChallenge" {
   source = "..//cognitolambda"

  lambdaName = "defineAuthChallenge"
  bucketID = aws_s3_bucket.lamdbabucket.id
  cognitoPoolArn = aws_cognito_user_pool.sandbox_userpool.arn
  lambdaRoleArn = aws_iam_role.defineAuth_lambda_iam_role.arn
}

module "postAuthentication" {
   source = "..//cognitolambda"

  lambdaName = "postAuthentication"
  bucketID = aws_s3_bucket.lamdbabucket.id
  cognitoPoolArn = aws_cognito_user_pool.sandbox_userpool.arn
  lambdaRoleArn = aws_iam_role.postAuth_lambda_role.arn
}

module "preSignup" {
   source = "..//cognitolambda"

  lambdaName = "preSignup"
  bucketID = aws_s3_bucket.lamdbabucket.id
  cognitoPoolArn = aws_cognito_user_pool.sandbox_userpool.arn
  lambdaRoleArn = aws_iam_role.preSignup_lambda_role.arn
}

module "verifyAuthChallenge" {
   source = "..//cognitolambda"

  lambdaName = "verifyAuthChallenge"
  bucketID = aws_s3_bucket.lamdbabucket.id
  cognitoPoolArn = aws_cognito_user_pool.sandbox_userpool.arn
  lambdaRoleArn = aws_iam_role.verifyAuth_lambda_role.arn
}

# This is not actually triggered from cognito but at this point we shall
# create it like the others. It right now it gains permissions to be
# invoked from cognito and it has to be dealt at some point, especially
# if other lambdas also come in question.
module "signIn" {
   source = "..//cognitolambda"

  lambdaName = "signIn"
  bucketID = aws_s3_bucket.lamdbabucket.id
  cognitoPoolArn = aws_cognito_user_pool.sandbox_userpool.arn
  lambdaRoleArn = aws_iam_role.signIn_lambda_iam_role.arn
  env_vars = {
        "SES_FROM_ADDRESS" = var.ses_from_address
        "USER_POOL_ID" = aws_cognito_user_pool.sandbox_userpool.id
      }
}
