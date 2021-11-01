resource "aws_iam_group" "group" {
  for_each = var.iam_groups
  name     = var.iam_groups[each.key]
  path     = "/"


resource "aws_iam_user" "users" {
  for_each      = var.iam_user
  name          = var.iam_user[each.key]["name"]
  path          = "/"
  force_destroy = true
}

resource "aws_iam_group_membership" "admins" {
  name     = "admin-members"
  users = [for i in var.iam_user : var.iam_user[i]["name"] if var.iam_user[i]["group"] == "admin" ]
  group = "admin"
}

locals = {
  adminepolicy = "../policies/json/AdministratorAccess.json"
}

resource "aws_iam_group_policy" "admins" {
  name  = "admin_policy"
  group = "admins"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = fileexists(local.adminpolicy)? file(local.adminpolicy) : null;

}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 12
  password_reuse_prevention      = true
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}