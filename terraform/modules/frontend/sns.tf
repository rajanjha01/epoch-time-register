##KMS Key to use for SNS Topic

resource "aws_kms_key" "epochkey" {
  description             = "KMS key for epoch SNS topic"
  policy                  = data.aws_iam_policy_document.epochkey_policy_document.json
  deletion_window_in_days = 30

}
resource "aws_kms_alias" "epochkey-alias" {
  name          = "alias/epochkey"
  target_key_id = aws_kms_key.epochkey.key_id
}

data "aws_iam_policy_document" "epochkey_policy_document" {
  statement {
    sid       = "EnableIAMrootpermissions"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
    }
  }
  statement {
    sid    = "AllowCloudWatchforCMK"
    effect = "Allow"
    resources = [
      "*"
    ]
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }
}
output "key_arn" {
  value = aws_kms_key.epochkey.arn
}
##SNS Topic to send all the CW alarms and notify the users in the FMB

resource "aws_sns_topic" "epoch-prod" {
  name              = "epoch-prod-alerts"
  display_name      = "epoch-prod-alerts"
  kms_master_key_id = "alias/epochkey"
}

resource "aws_sns_topic_policy" "epoch-us-prod_sns_policy" {
  arn = aws_sns_topic.epoch-prod.arn

  policy = data.aws_iam_policy_document.epoch-us-prod_sns_policy_document.json
}

data "aws_iam_policy_document" "epoch-us-prod_sns_policy_document" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.aws_account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.epoch-prod.arn
      ,
    ]

    sid = "__default_statement_ID"
  }
}

## SNS Subscription to email

resource "aws_sns_topic_subscription" "epoch-us-prod_target" {
  topic_arn = aws_sns_topic.epoch-prod.arn

  protocol = "email"
  endpoint = "jha.rajan1987@gmail.com"
}
##################################################################