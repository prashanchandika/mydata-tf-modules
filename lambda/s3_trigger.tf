data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/s3/terraform.tfstate"
    region = var.backend_region
  }
}


locals {
    s3_arn = data.terraform_remote_state.s3.outputs.s3["arn"]
    s3_name = data.terraform_remote_state.s3.outputs.s3["name"]
}

resource "aws_lambda_permission" "allow_bucket" {
  count     = var.lambda_trigger == "s3" ? 1 : 0

  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda1.arn
  principal     = "s3.amazonaws.com"
  source_arn    = local.s3_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count     = var.lambda_trigger == "s3" ? 1 : 0
  bucket = local.s3_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda1.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "ldz"
    #filter_suffix       = "*" 
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

# SNS Trigger
resource "aws_lambda_permission" "sns" {
  count         =  var.lambda_trigger == "sns" ? 1 : 0
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda1.id
  principal     = "sns.amazonaws.com"
  statement_id  = "AllowSubscriptionToSNS"
  source_arn    = aws_sns_topic.sns1.arn
}

resource "aws_sns_topic_subscription" "subscription" {
  count     = var.lambda_trigger == "sns" ? 1 : 0
  endpoint  = aws_lambda_function.lambda1.arn
  protocol  = "lambda"
  topic_arn = aws_sns_topic.sns1.arn
}

resource "aws_sns_topic" "sns1" {
  name = "${var.product}-${var.deployment_identifier}"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false
  }
}
EOF
}