module "lambda_cloudwatch_alert" {
  count          = var.enable_lambda_cw_alert ? 1 : 0
  source         = "github.com/champ-oss/terraform-aws-alert.git?ref=v1.0.110-f1d3b01"
  git            = var.git
  log_group_name = aws_cloudwatch_log_group.this.name
  name           = var.name
  filter_pattern = var.filter_pattern
  slack_url      = var.slack_url
  region         = var.alert_region
}
