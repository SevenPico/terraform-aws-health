## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./health-lambda.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Health Lambda
# ------------------------------------------------------------------------------
module "health_lambda" {
  source     = "SevenPicoForks/lambda-function/aws"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["lambda"]

  architectures                       = null
  cloudwatch_event_rules              = {}
  cloudwatch_lambda_insights_enabled  = false
  cloudwatch_logs_kms_key_arn         = ""
  cloudwatch_logs_retention_in_days   = 90
  cloudwatch_log_subscription_filters = {}
  description                         = "Health Check Lambda"
  event_source_mappings               = {}
  filename                            = "${path.module}/lambdas/health/lambda.zip"
  source_code_hash                    = filebase64sha256("${path.module}/lambdas/health/lambda.zip")
  function_name                       = var.unique_dashboard_name_enabled ? "${module.context.namespace}-${module.context.environment}-${var.unique_dashboard_name}-lambda" : module.context.id
  handler                             = "bootstrap"
  ignore_external_function_updates    = false
  image_config                        = {}
  image_uri                           = null
  kms_key_arn                         = ""
  lambda_at_edge                      = false
  layers                              = []
  memory_size                         = 512
  package_type                        = "Zip"
  publish                             = false
  reserved_concurrent_executions      = var.reserved_concurrent_executions
  role_name                           = var.unique_dashboard_name_enabled ? "${module.context.namespace}-${module.context.environment}-${var.unique_dashboard_name}-lambda-role" :"${module.context.id}-lambda-role"
  runtime                             = "provided.al2"
  s3_bucket                           = null
  s3_key                              = null
  s3_object_version                   = null
  sns_subscriptions                   = {}
  ssm_parameter_names                 = null
  timeout                             = 60
  tracing_config_mode                 = null
  # vpc_config = {
  #   security_group_ids = var.security_group_ids
  #   subnet_ids         = var.subnet_ids
  # }
}

# module "health_lambda_external" {
#   source     = "app.terraform.io/SevenPico/lambda-function/aws"
#   version    = "0.1.0.2"
#   context    = module.context.self
#   attributes = ["lambda-external"]

#   architectures                       = null
#   cloudwatch_event_rules              = {}
#   cloudwatch_lambda_insights_enabled  = false
#   cloudwatch_logs_kms_key_arn         = ""
#   cloudwatch_logs_retention_in_days   = 90
#   cloudwatch_log_subscription_filters = {}
#   description                         = "Health Check Lambda"
#   event_source_mappings               = {}
#   filename                            = "${path.module}/lambdas/health-lambda.zip"
#   source_code_hash                    = filebase64sha256("${path.module}/lambdas/health-lambda.zip")
#   function_name                       = module.context.id
#   handler                             = "lambda"
#   ignore_external_function_updates    = false
#   image_config                        = {}
#   image_uri                           = null
#   kms_key_arn                         = ""
#   lambda_at_edge                      = false
#   layers                              = []
#   memory_size                         = 512
#   package_type                        = "Zip"
#   publish                             = false
#   reserved_concurrent_executions      = 10
#   role_name                           = "${module.context.id}-lambda-external-role"
#   runtime                             = "go1.x"
#   s3_bucket                           = null
#   s3_key                              = null
#   s3_object_version                   = null
#   sns_subscriptions                   = {}
#   ssm_parameter_names                 = null
#   timeout                             = 60
#   tracing_config_mode                 = null
# }

resource "aws_iam_role_policy_attachment" "health_lambda" {
  count      = module.context.enabled ? 1 : 0
  role       = var.unique_dashboard_name_enabled ? "${module.context.namespace}-${module.context.environment}-${var.unique_dashboard_name}-lambda-role" : "${module.context.id}-lambda-role"
  policy_arn = module.health_lambda_policy.policy_arn
}

# resource "aws_iam_role_policy_attachment" "health_lambda_external" {
#   count      = module.context.enabled ? 1 : 0
#   role       = "${module.context.id}-lambda-external-role"
#   policy_arn = module.health_lambda_policy.policy_arn
# }

module "health_lambda_policy" {
  source     = "SevenPicoForks/iam-policy/aws"
  version    = "2.0.0"
  context    = module.context.self
  attributes = var.unique_dashboard_name_enabled ? ["default", "dashboard", "lambda", "policy"] : ["lambda", "policy"]

  description                   = "Lambda Access Policy"
  iam_override_policy_documents = null
  iam_policy_enabled            = true
  iam_policy_id                 = null
  iam_source_json_url           = null
  iam_source_policy_documents   = null

  iam_policy_statements = {
    # FIXME - limit the permissions here
    All = {
      effect    = "Allow"
      actions   = ["ssm:*", "codepipeline:*", "kms:*", "ec2:*"]
      resources = ["*"]
    }
  }
}
