
### IAM role for epoch lambda fundtion

data "aws_iam_policy_document" "epochhandler_role_assume_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    sid     = "LambdaServiceAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "epochhandler-iam-role" {
  name               = "epochhandler-iam-role"
  assume_role_policy = data.aws_iam_policy_document.epochhandler_role_assume_policy.json
}

# A simple IAM policy document
data "aws_iam_policy_document" "epochhandler_iam_policy_doc" {
  statement {
    sid    = ""
    effect = "Allow"
    resources = [
      "arn:aws:logs:*:*:*"
    ]
    actions = [
      "logs:PutLogEvents",
      "logs:DescribeLogStream",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:StartQuery",
      "logs:GetQueryResults"
    ]
  }
  statement {
    sid    = ""
    effect = "Allow"
    resources = [
      "*"
    ]
    actions = [
      "dynamodb:*"
    ]
  }
  statement {
    sid    = ""
    effect = "Allow"
    resources = [
      "*"
    ]
    actions = [
      "s3:*"
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"
    resources = [
      "*"
    ]
    actions = [
      "kms:*"
    ]
  }
}

# Create the policy 
resource "aws_iam_policy" "epochhandler_iam_policy" {
  name        = "epochhandler"
  description = "epochhandler"
  policy      = data.aws_iam_policy_document.epochhandler_iam_policy_doc.json
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "epochhandler_iam_policy_attach" {
  role       = aws_iam_role.epochhandler-iam-role.name
  policy_arn = aws_iam_policy.epochhandler_iam_policy.arn
}
############################################################