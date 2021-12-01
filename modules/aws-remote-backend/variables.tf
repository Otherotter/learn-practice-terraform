variable "region" {
  description = "Region Used for Application"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Bucket name of where the remote backend for terraform's state location"
  type = string
  default = "terraform-remote-backend"
}

