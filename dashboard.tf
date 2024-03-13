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
##  ./dashboard.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Health Dashboard
# ------------------------------------------------------------------------------
locals {
  alarm_widgets = [
    for group in var.cloudwatch_alarm_groups : {
      type   = "alarm"
      width  = 24
      height = ceil(length(group.alarm_arns) / 8)
      properties = {
        title  = group.title
        alarms = group.alarm_arns
      }
    }
  ]

  http_status_widgets = [
    for group in var.http_status_groups : {
      type   = "custom"
      width  = 24
      height = 2 * length(group.endpoints)
      properties = {
        title = group.title
        #endpoint = module.health_lambda_external.arn
        endpoint = module.health_lambda.arn
        params = {
          kind      = "http"
          mode      = "html"
          endpoints = group.endpoints
        }
        updateOn = {
          refresh   = true
          resize    = true
          timeRange = true
        },
      }
    }
  ]

  cicd_widgets = [
    for group in var.cicd_pipeline_groups : {
      type   = "custom"
      width  = 24
      height = 2 * length(group.pipelines)
      properties = {
        title = group.title
        #endpoint = module.health_lambda_external.arn
        endpoint = module.health_lambda.arn
        params = {
          mode      = "html"
          kind      = "cicd"
          pipelines = group.pipelines
        }
      }
      updateOn = {
        refresh   = true
        resize    = true
        timeRange = true
      },
    }
  ]
}

resource "aws_cloudwatch_dashboard" "health" {
  count          = module.context.enabled ? 1 : 0
  dashboard_name = module.context.id
  dashboard_body = jsonencode({
    periodOverride = "inherit"
    widgets        = concat(local.alarm_widgets, local.http_status_widgets, local.cicd_widgets, var.additional_widgets)
  })
}
