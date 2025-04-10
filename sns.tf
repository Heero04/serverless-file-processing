# SNS topic for notifying when conversion process is complete
resource "aws_sns_topic" "conversion_complete" {
  name = "conversion-complete-${terraform.workspace}"
}

# Sends notifications to specified email address when messages are published
resource "aws_sns_topic_subscription" "email_notify" {
  topic_arn = aws_sns_topic.conversion_complete.arn
  protocol  = "email"
  endpoint  = "lawrencedavis1010@gmail.com" # 👈 Replace with your real email
}
