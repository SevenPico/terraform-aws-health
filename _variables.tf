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
##  ./_variables.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

variable "cloudwatch_alarm_groups" {
  type = list(object({
    title      = string
    alarm_arns = list(string)
  }))
  default = []
}

variable "http_status_groups" {
  type = list(object({
    title = string
    endpoints = map(object({
      url   = string
      query = string
    }))
  }))
  default = []
}

variable "cicd_pipeline_groups" {
  type = list(object({
    title = string
    pipelines = map(object({
      target_kind        = string
      codepipeline_name  = string
      ssm_parameter_name = string
    }))
  }))
  default = []
}

# variable "subnet_ids" {
#   type    = list(string)
#   default = []
# }

# variable "security_group_ids" {
#   type    = list(string)
#   default = []
# }

variable "additional_widgets" {
  type    = any
  default = []
}

variable "notify_sns_topic_arn" {
  type = string
}

variable "reserved_concurrent_executions" {
  type        = number
  default     = 10
  description = "The number of reserved concurrent executions for the Lambda function. This setting ensures that a specified number of function instances are always available to process events. Adjust this value to balance the concurrency needs of the function with the overall account concurrency limits."
}

variable "unique_dashboard_name_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether to enable the creation of a unique dashboard name. When set to true, the Terraform configuration will generate a unique name for a CloudWatch dashboard. Default is false."
}

variable "unique_dashboard_name" {
  type        = string
  default     = ""
  description = "The unique name to be used for a CloudWatch dashboard. If provided, this name will be used instead of automatically generating one when 'unique_dashboard_name_enabled' is set to true."
}

# variable "sns_pub_principals" {
#   type    = map(list(string))
#   default = {}
# }

# variable "sns_sub_principals" {
#   type    = map(list(string))
#   default = {}
# }

# variable "cloudwatch_log_expiration_days" {
#   type    = string
#   default = 90
# }

# variable "slack_notifications_enabled" {
#   type    = bool
#   default = false
# }

# variable "slack_channel_ids" {
#   type    = list(string)
#   default = []
# }

# variable "slack_token_secret_arn" {
#   type    = string
#   default = ""
# }

# variable "slack_token_secret_kms_key_arn" {
#   type    = string
#   default = ""
# }
