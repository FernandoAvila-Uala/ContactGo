resource "aws_lambda_function" "create_contact_lambda" {
  filename      = "createContactGo.zip"
  function_name = "CreateContactFerAvilaGo"
  role          = "arn:aws:iam::620097380428:role/ContactRole"
  handler       = "main"
  runtime       = "go1.x"
}

data "aws_api_gateway_rest_api" "contact_api_fer_avila" {
  name= "ContactFerAvilApiGateway"
}

resource "aws_api_gateway_resource" "create_contact_resource" {
  rest_api_id = data.aws_api_gateway_rest_api.contact_api_fer_avila.id
  parent_id   = data.aws_api_gateway_rest_api.contact_api_fer_avila.root_resource_id
  path_part   = "create-contact-go"
}

resource "aws_api_gateway_method" "create_contact_method" {
  rest_api_id   = data.aws_api_gateway_rest_api.contact_api_fer_avila.id
  resource_id   = aws_api_gateway_resource.create_contact_resource.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id  = aws_api_gateway_authorizer.authorizer.id
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name= "Tianshu_Auth"
  rest_api_id   = data.aws_api_gateway_rest_api.contact_api_fer_avila.id
  authorizer_uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:620097380428:function:auth0-authorizer-service-tianshu/invocations"
  type= "TOKEN"
  identity_source = "method.request.header.Authorization"
}


resource "aws_api_gateway_integration" "create_contact_integration" {
  rest_api_id = "nkw0o0ksec"
  resource_id = aws_api_gateway_resource.create_contact_resource.id
  integration_http_method = "POST"
  http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.create_contact_lambda.invoke_arn
}

resource "aws_lambda_permission" "apigateway_permission_authorizer" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:us-east-1:620097380428:function:auth0-authorizer-service-tianshu"
  principal     = "apigateway.amazonaws.com"
  source_arn   = data.aws_api_gateway_rest_api.contact_api_fer_avila.execution_arn
}

resource "aws_lambda_permission" "apigateway_permission_create_contact" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action= "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_contact_lambda.function_name
  principal= "apigateway.amazonaws.com"
  source_arn= data.aws_api_gateway_rest_api.contact_api_fer_avila.execution_arn
}