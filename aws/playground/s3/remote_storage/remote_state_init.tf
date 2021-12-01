resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "remote_backend" {
  bucket = "terraform-remote-backend"
  acl = "private"
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

# resource "aws_dynamodb_table" "terraform_locks" {
#  name = "terraform-state-locking"
#  billing_mode = "PAY_PER_REQUEST"
#  hash_key = "LockID"
#  attribute {
#    name = "LockID"
#    type = "S"
#  }
#}
