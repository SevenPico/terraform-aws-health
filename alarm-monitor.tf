# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# TODO - use cross-account event bridge target instead
# module "alarm_event" {
#   source     = "app.terraform.io/SevenPico/events/aws//cloudwatch-event"
#   version    = "0.0.1"
#   context    = module.context.self
#   attributes = ["alarm"]

#   description = "Event to trigger on any CloudWatch Alarm"
#   target_arn  = var.notify_sns_topic_arn

#   event_pattern = jsonencode({
#     source      = ["aws.cloudwatch"]
#     detail-type = ["CloudWatch Alarm State Change"]
#     detail = {
#       alarmName = flatten([
#         for group in var.cloudwatch_alarm_groups : [
#           for arn in group.alarm_arns : reverse(split(":", arn))[0]
#       ]])
#     }
#   })

#   transformer = {
#     template = jsonencode({
#       topic = "ALERT"
#       message = {
#         text = "Alarm in ${module.context.id}: <alarm_name>"
#         blocks = [
#           {
#             type = "section"
#             text = {
#               type = "plain_text"
#               text = "<alarm_reason>"
#             }
#           },
#           {
#             type = "context"
#             elements = [
#               { type = "plain_text", text = "Timestamp: <alarm_timestamp>" },
#             ]
#           }
#         ]
#       }
#     })

#     paths = {
#       alarm_name      = "$.detail.alarmName"
#       alarm_reason    = "$.detail.state.reason"
#       alarm_timestamp = "$.detail.state.timestamp"
#     }
#   }
# }
