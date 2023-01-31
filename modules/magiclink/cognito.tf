resource "aws_cognito_user_pool" "sandbox_userpool" {
  name = "sandbox-${var.product}-${var.environment}-userpool-userpool"

  password_policy {
    require_numbers = false
    require_symbols = false
    require_uppercase = false
    minimum_length = 6
  }

  #alias_attributes = ["email" ]
  username_attributes = ["email" ]
  
  username_configuration {
    case_sensitive = true
  }


  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  #schema for email attribute
  schema {
    name = "email"
    attribute_data_type = "String"
    developer_only_attribute = false
    required = true
    mutable = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  #Custom attribute authChallenge
  schema {
    name = "authChallenge"
    attribute_data_type = "String"
    developer_only_attribute = false
    required = false
    mutable = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  lambda_config {
    
    create_auth_challenge = module.createAuthChallenge.lambda_arn
    define_auth_challenge = module.defineAuthChallenge.lambda_arn
    pre_sign_up = module.preSignup.lambda_arn
    post_authentication = module.postAuthentication.lambda_arn
    verify_auth_challenge_response = module.verifyAuthChallenge.lambda_arn
  }

  email_configuration {
    email_sending_account = "DEVELOPER"
    from_email_address = var.ses_from_address
    source_arn = aws_ses_email_identity.ses_from_address.arn
  }
}


resource "aws_cognito_user_pool_client" "sandbox_userpool_client" {
  name = "sandbox-${var.product}-${var.environment}-userpool-client"

  user_pool_id = aws_cognito_user_pool.sandbox_userpool.id
  callback_urls = ["https://example.com"]
  allowed_oauth_flows_user_pool_client = true
  #generate_secret  = true

  refresh_token_validity = 30
  access_token_validity = 1
  id_token_validity = 1

  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["phone","email","openid"]
  supported_identity_providers = ["COGNITO"]

  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"
}
