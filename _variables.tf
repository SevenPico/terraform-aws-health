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
  type    = list(any)
  default = []
}

variable "notify_sns_topic_arn" {
  type = string
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
