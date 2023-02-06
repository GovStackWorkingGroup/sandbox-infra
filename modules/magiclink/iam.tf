data "aws_iam_policy_document" "lambda_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
# Roles for lambdas

resource "aws_iam_role" "createAuth_lambda_iam_role" {
  name = "createAuthChallengeLambdaIamRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json
}

resource "aws_iam_role" "defineAuth_lambda_iam_role" {
  name = "defineAuthChallengeeLambdaIamRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json
}

resource "aws_iam_role" "postAuth_lambda_role" {
  name = "PostAuthLambdaIamRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json
}

resource "aws_iam_role" "preSignup_lambda_role" {
  name = "PreSignUpLambdaIamRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json
}

resource "aws_iam_role" "verifyAuth_lambda_role" {
  name = "verifyAuthChallengeLambdaIamRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json
}

resource "aws_iam_role" "signIn_lambda_iam_role" {
  name = "SignInLambdaIamRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json
}


# Policy for SES email sending for SignIn

data "aws_iam_policy_document" "signin_lambda_ses_policy_document" {
  statement {
    sid = "LambdaSendEmailSES"
    actions = [
      "ses:sendEmail"
    ]
    resources = [
      aws_ses_email_identity.ses_from_address.arn
      ]
  }
}

resource "aws_iam_policy" "signIn_lambda_ses_policy" {
  name   = "LambdaSendEmailSESPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.signin_lambda_ses_policy_document.json
}

resource "aws_iam_role_policy_attachment" "ses_policy_attachment" {
  role = aws_iam_role.signIn_lambda_iam_role.name
  policy_arn = aws_iam_policy.signIn_lambda_ses_policy.arn
  depends_on = [
    aws_iam_policy.signIn_lambda_ses_policy
  ]
}


#Policy for cognito update for postAuthentication and SignIn

data "aws_iam_policy_document" "lambda_update_cognito_documment" {
  statement {
    sid = "LambdaUpdateCognito"
    actions = [
      "cognito-idp:AdminUpdateUserAttributes"
    ]
    resources = [
      aws_cognito_user_pool.sandbox_userpool.arn
    ]
  }
}

resource "aws_iam_policy" "lamda_update_cognito_policy" {
  name   = "LambdaUpdateCognitoPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_update_cognito_documment.json
}


# Attach cognito policy for signin and postauth

resource "aws_iam_role_policy_attachment" "postauth_cognito_policy_attachment" {
  role = aws_iam_role.postAuth_lambda_role.name
  policy_arn = aws_iam_policy.lamda_update_cognito_policy.arn
  depends_on = [
    aws_iam_policy.lamda_update_cognito_policy
  ]
}

resource "aws_iam_role_policy_attachment" "signIn_cognito_policy_attachment" {
  role = aws_iam_role.signIn_lambda_iam_role.name
  policy_arn = aws_iam_policy.lamda_update_cognito_policy.arn
  depends_on = [
    aws_iam_policy.lamda_update_cognito_policy
  ]
}

#kato mitkä lambdat vaati mitäkin noista
#ehkäpä yksi rooli muille, omat niille mitkä vaatii
