output "password" {
  value = aws_iam_access_key.test.ses_smtp_password_v4
  sensitive = true
}
